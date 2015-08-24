assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../dist/vigor.componentmanager'

componentManager = new Vigor.ComponentManager()
__testOnly = Vigor.ComponentManager.__testOnly

clock = undefined

class MockComponent

  $el: undefined
  attr: undefined

  constructor: (attr) ->
    @attr = attr
    @$el = $ '<div clas="mock-component"></div>'
    if @attr?.id
      @$el.attr 'id', @attr?.id

  delegateEvents: ->
    eventsDelegated = true
    return eventsDelegated

  render: ->
    return @

  onAddedToDom: ->
    return @

class MockComponent2
  $el: undefined
  attr: undefined
  constructor: (attr) ->
    @attr = attr
    @$el = $ '<div clas="mock-component2"></div>'

  render: ->
    return @

window.MockComponent = MockComponent
window.MockComponent2 = MockComponent2

describe 'The componentManager', ->
  sandbox = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()
    clock = sinon.useFakeTimers()

  afterEach ->
    do componentManager.dispose
    do sandbox.restore
    do clock.restore

  describe 'ComponentManagers prototype extends', ->
    it 'underscore events', ->
      assert Vigor.ComponentManager.prototype.on
      assert Vigor.ComponentManager.prototype.off
      assert Vigor.ComponentManager.prototype.once
      assert Vigor.ComponentManager.prototype.listenTo
      assert Vigor.ComponentManager.prototype.listenToOnce
      assert Vigor.ComponentManager.prototype.bind
      assert Vigor.ComponentManager.prototype.unbind
      assert Vigor.ComponentManager.prototype.trigger
      assert Vigor.ComponentManager.prototype.stopListening

  describe 'public methods', ->
    describe 'initialize', ->
      it 'instantiate necessary collections and models', ->
        assert.equal componentManager._componentDefinitionsCollection, undefined
        assert.equal componentManager._instanceDefinitionsCollection, undefined
        assert.equal componentManager._activeInstancesCollection, undefined
        assert.equal componentManager._globalConditionsModel, undefined
        assert.equal componentManager._filterModel, undefined

        do componentManager.initialize

        assert componentManager._componentDefinitionsCollection
        assert componentManager._instanceDefinitionsCollection
        assert componentManager._activeInstancesCollection
        assert componentManager._globalConditionsModel
        assert componentManager._filterModel

      it 'should call setComponentClassName', ->
        setComponentClassName = sandbox.spy componentManager, 'setComponentClassName'
        do componentManager.initialize
        assert setComponentClassName.called

      it 'should call setTargetPrefix', ->
        setTargetPrefix = sandbox.spy componentManager, 'setTargetPrefix'
        do componentManager.initialize
        assert setTargetPrefix.called

      it 'should call addListeners', ->
        addListeners = sandbox.spy componentManager, 'addListeners'
        do componentManager.initialize
        assert addListeners.called

      it 'should call _parse with passed settings', ->
        settings =
          targetPrefix: 'dummy-prefix'

        parseSpy = sandbox.spy componentManager, '_parse'
        componentManager.initialize settings
        assert parseSpy.calledWith settings

      it 'should return the componentManager for chainability', ->
        cm = componentManager.initialize()
        assert.equal cm, componentManager

    describe 'updateSettings', ->
      it 'should call _parse with passed settings', ->
        settings =
          targetPrefix: 'dummy-prefix'

        parseSpy = sandbox.stub componentManager, '_parse'
        componentManager.updateSettings settings
        assert parseSpy.calledWith settings

      it 'should return the componentManager for chainability', ->
        cm = componentManager.updateSettings()
        assert.equal cm, componentManager

    describe 'refresh', ->
      it 'should set and parse the filterOptions if passed', ->
        filterOptions =
          url: 'foo'

        do componentManager.initialize
        parsedFilterOptions = componentManager._filterModel.parse filterOptions

        filterModelSet = sandbox.stub componentManager._filterModel, 'set'
        filterModelParse = sandbox.spy componentManager._filterModel, 'parse'

        componentManager.refresh filterOptions

        assert filterModelParse.calledWith filterOptions
        assert filterModelSet.calledWith parsedFilterOptions

      it 'clear the filterModel and update activeComponents if no filterOptions was passed', ->
        do componentManager.initialize
        filterModelClear = sandbox.spy componentManager._filterModel, 'clear'
        updateActiveComponents = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.refresh
        assert filterModelClear.called
        assert updateActiveComponents.called

      it 'should return the componentManager for chainability', ->
        do componentManager.initialize
        cm = componentManager.refresh()
        assert.equal cm, componentManager

    describe 'serialize', ->
      settings = undefined
      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'
        settings =
          $context: '.test-prefix--header'
          componentClassName: 'test-component'
          targetPrefix: 'test-prefix'
          componentSettings:
            conditions:
              isValWithinLimit: ->
                limit = 300
                val = 100
                return val < limit

            components: [
              {
                id: 'mock-component',
                src: 'window.MockComponent'
              }
            ]

            instances: [
              {
                id: 'instance-1',
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 1
                args:
                  id: 'instance-1'
              }
            ]

      afterEach ->
        do $('.test-prefix--header').remove

      it 'should call toJSON on the globalConditionsModel', ->
        componentManager.initialize settings
        toJSONSpy = sandbox.spy componentManager._globalConditionsModel, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call toJSON on the _componentDefinitionsCollection', ->
        componentManager.initialize settings
        toJSONSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call toJSON on the _instanceDefinitionsCollection', ->
        componentManager.initialize settings
        toJSONSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call getComponentClassName', ->
        componentManager.initialize settings
        getComponentClassNameSpy = sandbox.spy componentManager, 'getComponentClassName'
        do componentManager.serialize
        assert getComponentClassNameSpy.called

      it 'should call getTargetPrefix', ->
        componentManager.initialize settings
        getTargetPrefixSpy = sandbox.spy componentManager, 'getTargetPrefix'
        do componentManager.serialize
        assert getTargetPrefixSpy.called

      it 'should stringify current state of the componentManager so that it can
      be parsed back at a later time', ->
        componentManager.initialize settings
        serialized = do componentManager.serialize
        parsed = componentManager.parse serialized

        firstSettingsInstance = settings.componentSettings.instances[0]
        firstParsedInstance = parsed.componentSettings.instances[0]

        assert parsed
        assert.equal parsed.$context, settings.$context
        assert.equal parsed.componentClassName, settings.componentClassName
        assert.equal parsed.targetPrefix, settings.targetPrefix

        assert.equal JSON.stringify(parsed.componentSettings.conditions), JSON.stringify(settings.componentSettings.conditions)
        assert.equal parsed.componentSettings.conditions.isValWithinLimit(), settings.componentSettings.conditions.isValWithinLimit()

        assert.equal firstParsedInstance.id, firstSettingsInstance.id
        assert.equal firstParsedInstance.componentId, firstSettingsInstance.componentId
        assert.equal firstParsedInstance.targetName, firstSettingsInstance.targetName
        assert.equal firstParsedInstance.urlPattern, firstSettingsInstance.urlPattern
        assert.equal firstParsedInstance.order, firstSettingsInstance.order
        assert.deepEqual firstParsedInstance.args, firstSettingsInstance.args

    describe 'parse', ->
      settings =
        componentClassName: 'test-class-name'
        $context: $ '<div class="test"></div>'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: 'test-condition': false
          hidden: []
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'test-prefix--main'
            }
          ]

      expectedResults =
        componentClassName: 'test-class-name'
        $context: 'div.test'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: 'test-condition': false
          hidden: []
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header'
              reInstantiateOnUrlParamChange: false
              showCount: 0
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'test-prefix--main'
              reInstantiateOnUrlParamChange: false
              showCount: 0
            }
          ]

      it 'should be able to parse the output of serialize back into usable settings', ->
        serializedResults = componentManager.initialize(settings).serialize()
        results = componentManager.parse serializedResults

        # clean out the added urlParamsModel (a backbone model with generated
        # uniqe id since its id wont be predictable)
        for instance in results.componentSettings.instances
          delete instance.urlParamsModel

        assert.deepEqual results, expectedResults

      it 'should be able to parse settings that contains methods as condition', ->
        settings.componentSettings.conditions = dummyCondition: ->
          if 500 > 400 then return 30

        serializedResults = componentManager.initialize(settings).serialize()
        results = componentManager.parse serializedResults
        conditionResult = results.componentSettings.conditions.dummyCondition()

        # clean out the added urlParamsModel (a backbone model with generated
        # uniqe id since its id wont be predictable)
        for instance in results.componentSettings.instances
          delete instance.urlParamsModel

        delete expectedResults.componentSettings.conditions
        # cleaning out the method since it seems sinon cant compare them properly,
        # the result is verified by the condition result though
        delete results.componentSettings.conditions

        assert.deepEqual results, expectedResults
        assert.equal conditionResult, 30

      it 'should call updateSettings if second param is true', ->
        updateSettings = true
        updateSettingsStub = sandbox.stub componentManager, 'updateSettings'
        serializedResults = componentManager.initialize(settings).serialize()
        componentManager.parse serializedResults, updateSettings
        assert updateSettingsStub.called

    describe 'clear', ->
      beforeEach ->
        $('body').append '<div class="clear-test"></div>'
        $('.clear-test').append '<div class="test-prefix--header"></div>'

        settings =
          componentClassName: 'test-class-name'
          $context: '.clear-test'
          targetPrefix: 'test-prefix'
          componentSettings:
            conditions: 'test-condition': false
            hidden: []
            components: [
              {
                id: 'mock-component',
                src: 'window.MockComponent'
              }
            ]
            instances: [
              {
                id: 'instance-1',
                urlPattern: 'foo/:id'
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
              },
              {
                id: 'instance-2',
                urlPattern: 'bar/:id'
                componentId: 'mock-component',
                targetName: 'test-prefix--main'
              }
            ]
        componentManager.initialize settings

      afterEach ->
        do componentManager.dispose
        do $('.clear-test').remove

      it 'should remove all components', ->
        components = componentManager.getComponents()
        assert.equal components.length, 1

        do componentManager.clear

        components = componentManager.getComponents()
        assert.equal components.length, 0

      it 'should remove all instances', ->
        components = componentManager.getInstances()
        assert.equal components.length, 2

        do componentManager.clear

        components = componentManager.getInstances()
        assert.equal components.length, 0

      it 'should remove all activeComponents', ->
        componentManager.refresh
          url: 'foo/1'

        instances = componentManager.getActiveInstances()
        assert.equal instances.length, 1

        do componentManager.clear

        instances = componentManager.getInstances()
        assert.equal instances.length, 0

      it 'should remove all filters', ->
        componentManager.refresh
          url: 'foo/1'

        filter = componentManager.getActiveFilter()
        expectedResults =
          url: 'foo/1'
          includeIfStringMatches: undefined
          hasToMatchString: undefined
          cantMatchString: undefined

        assert.deepEqual filter, expectedResults

        do componentManager.clear
        filter = componentManager.getActiveFilter()
        expectedResults = {}

        filter = componentManager.getActiveFilter()
        assert.deepEqual filter, expectedResults

      it 'should clear all global conditions', ->
        condition = componentManager.getConditions()
        globalCondition = 'test-condition': false
        assert.deepEqual condition, globalCondition
        do componentManager.clear
        condition = componentManager.getConditions()
        assert.deepEqual condition, {}

      it 'should clear the context', ->
        $context = componentManager.getContext()
        assert.equal $context.length, 1

        do componentManager.clear

        $context = componentManager.getContext()
        assert.deepEqual $context, undefined

      it 'should reset the componentClassName to the default', ->
        componentClassName = componentManager.getComponentClassName()
        assert.equal componentClassName, 'test-class-name'

        do componentManager.clear

        componentClassName = componentManager.getComponentClassName()
        assert.equal componentClassName, 'vigor-component'

      it 'should reset the targetPrefix to the default', ->
        targetPrefix = componentManager.getTargetPrefix()
        assert.equal targetPrefix, 'test-prefix'

        do componentManager.clear

        targetPrefix = componentManager.getTargetPrefix()
        assert.equal targetPrefix, 'component-area'

      it 'should return the componentManager for chainability', ->
        cm = componentManager.clear()
        assert.equal cm, componentManager

    describe 'dispose', ->
      it 'should call clear', ->
        sandbox.spy componentManager, 'clear'
        do componentManager.dispose
        assert componentManager.clear.called

      it 'should call removeListeners', ->
        sandbox.spy componentManager, 'removeListeners'
        do componentManager.dispose
        assert componentManager.removeListeners.called

      it 'should set class instances to undefined', ->
        do componentManager.initialize
        assert componentManager._componentDefinitionsCollection
        assert componentManager._instanceDefinitionsCollection
        assert componentManager._activeInstancesCollection
        assert componentManager._globalConditionsModel
        assert componentManager._filterModel

        do componentManager.dispose
        assert.equal componentManager._componentDefinitionsCollection, undefined
        assert.equal componentManager._instanceDefinitionsCollection, undefined
        assert.equal componentManager._activeInstancesCollection, undefined
        assert.equal componentManager._globalConditionsModel, undefined
        assert.equal componentManager._filterModel, undefined

    describe 'addListeners', ->
      beforeEach ->
        componentManager._componentDefinitionsCollection = new __testOnly.ComponentDefinitionsCollection()
        componentManager._instanceDefinitionsCollection = new __testOnly.InstanceDefinitionsCollection()
        componentManager._activeInstancesCollection = new __testOnly.ActiveInstancesCollection()
        componentManager._globalConditionsModel = new Backbone.Model()
        componentManager._filterModel = new __testOnly.FilterModel()

      it 'should add a change listener on the filter model with _updateActiveComponents as callback', ->
        filterModelOnSpy = sandbox.spy componentManager._filterModel, 'on'
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.addListeners
        assert filterModelOnSpy.calledWith 'change', componentManager._updateActiveComponents

        componentManager._filterModel.trigger 'change'
        assert updateActiveComponentsSpy.called

      it 'should add a throttled_diff listener on the _componentDefinitionsCollection with _updateActiveComponents as callback', ->
        componentDefinitionsCollectionOnSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'on'
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.addListeners
        assert componentDefinitionsCollectionOnSpy.calledWith 'throttled_diff', componentManager._updateActiveComponents

        componentManager._componentDefinitionsCollection.trigger 'change', new Backbone.Model()
        assert.equal updateActiveComponentsSpy.called, false
        clock.tick 51
        assert updateActiveComponentsSpy.called

      it 'should add a throttled_diff listener on the _instanceDefinitionsCollection with _updateActiveComponents as callback', ->
        instanceDefinitionsCollectionOnSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'on'
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.addListeners
        assert instanceDefinitionsCollectionOnSpy.calledWith 'throttled_diff', componentManager._updateActiveComponents

        componentManager._instanceDefinitionsCollection.trigger 'change', new Backbone.Model()
        assert.equal updateActiveComponentsSpy.called, false
        clock.tick 51
        assert updateActiveComponentsSpy.called

      it 'should add a change listener on the gobal conditions model with _updateActiveComponents as callback', ->
        globalConditionsModelOnSpy = sandbox.spy componentManager._globalConditionsModel, 'on'
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.addListeners
        assert globalConditionsModelOnSpy.calledWith 'change', componentManager._updateActiveComponents

        componentManager._globalConditionsModel.trigger 'change'
        assert updateActiveComponentsSpy.called

      it 'should add a add listener on the _activeInstancesCollection with _onActiveInstanceAdd as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceAddSpy = sandbox.stub componentManager, '_onActiveInstanceAdd'

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'add', componentManager._onActiveInstanceAdd

        componentManager._activeInstancesCollection.add new Backbone.Model()
        assert onActiveInstanceAddSpy.called

      it 'should add change listeners on these params on the _activeInstancesCollection: componentId, filterString, conditions, args, showCount, urlPattern, urlParams, reInstantiateOnUrlParamChange with _onActiveInstanceChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceChangeSpy = sandbox.stub componentManager, '_onActiveInstanceChange'

        do componentManager.addListeners

        changes = 'change:componentId
                  change:filterString
                  change:conditions
                  change:args
                  change:showCount
                  change:urlPattern
                  change:urlParams
                  change:reInstantiateOnUrlParamChange'

        assert activeInstancesCollectionOnSpy.calledWith changes, componentManager._onActiveInstanceChange

        componentManager._activeInstancesCollection.trigger 'change:componentId', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:filterString', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:conditions', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:args', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:showCount', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:urlPattern', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:urlParams', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

        componentManager._activeInstancesCollection.trigger 'change:reInstantiateOnUrlParamChange', new Backbone.Model()
        assert onActiveInstanceChangeSpy.called
        do onActiveInstanceChangeSpy.reset

      it 'should add a change:order listener on the _activeInstancesCollection with _onActiveInstanceOrderChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceOrderSpy = sandbox.stub componentManager, '_onActiveInstanceOrderChange'

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'change:order', componentManager._onActiveInstanceOrderChange

        componentManager._activeInstancesCollection.trigger 'change:order', new Backbone.Model()
        assert onActiveInstanceOrderSpy.called

      it 'should add a change:targetName listener on the _activeInstancesCollection with _onActiveInstanceTargetNameChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceTargetNameChangeSpy = sandbox.stub componentManager, '_onActiveInstanceTargetNameChange'

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'change:targetName', componentManager._onActiveInstanceTargetNameChange

        componentManager._activeInstancesCollection.trigger 'change:targetName', new Backbone.Model()
        assert onActiveInstanceTargetNameChangeSpy.called

      it 'should add a change:remove listener on the _activeInstancesCollection with _onActiveInstanceRemoved as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceRemovedSpy = sandbox.stub componentManager, '_onActiveInstanceRemoved'
        sandbox.stub componentManager, '_onActiveInstanceAdd', ->

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'remove', componentManager._onActiveInstanceRemoved

        componentManager._activeInstancesCollection.add { id: 'dummy' }
        componentManager._activeInstancesCollection.remove 'dummy'
        assert onActiveInstanceRemovedSpy.called

      it 'should proxy add events from the _componentDefinitionsCollection (EVENTS.COMPONENT_ADD)', ->
        componentAddSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.COMPONENT_ADD, componentAddSpy
        componentManager._componentDefinitionsCollection.add new Backbone.Model()
        assert componentAddSpy.called

      it 'should proxy change events from the _componentDefinitionsCollection (EVENTS.COMPONENT_CHANGE)', ->
        componentChangeSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.COMPONENT_CHANGE, componentChangeSpy
        componentManager._componentDefinitionsCollection.trigger 'change', new Backbone.Model()
        assert componentChangeSpy.called

      it 'should proxy remove events from the _componentDefinitionsCollection (EVENTS.COMPONENT_REMOVE)', ->
        componentRemoveSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.COMPONENT_REMOVE, componentRemoveSpy
        componentManager._componentDefinitionsCollection.trigger 'remove', new Backbone.Model(), componentManager._componentDefinitionsCollection
        assert componentRemoveSpy.called

      it 'should proxy add events from the _instanceDefinitionsCollection (EVENTS.INSTANCE_ADD)', ->
        instanceAddSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.INSTANCE_ADD, instanceAddSpy
        componentManager._instanceDefinitionsCollection.add new Backbone.Model()
        assert instanceAddSpy.called

      it 'should proxy change events from the _instanceDefinitionsCollection (EVENTS.INSTANCE_CHANGE)', ->
        instanceChangeSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.INSTANCE_CHANGE, instanceChangeSpy
        componentManager._instanceDefinitionsCollection.trigger 'change', new Backbone.Model()
        assert instanceChangeSpy.called

      it 'should proxy remove events from the _instanceDefinitionsCollection (EVENTS.INSTANCE_REMOVE)', ->
        instanceRemoveSpy = sandbox.spy()
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.INSTANCE_REMOVE, instanceRemoveSpy
        componentManager._instanceDefinitionsCollection.trigger 'remove', new Backbone.Model(), componentManager._instanceDefinitionsCollection
        assert instanceRemoveSpy.called

      it 'should proxy add events from the _activeInstancesCollection (EVENTS.ADD)', ->
        addSpy = sandbox.spy()
        sandbox.stub componentManager, '_onActiveInstanceAdd'
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.ADD, addSpy
        componentManager._activeInstancesCollection.add new Backbone.Model()
        assert addSpy.called

      it 'should proxy change events from the _activeInstancesCollection (EVENTS.CHANGE)', ->
        changeSpy = sandbox.spy()
        sandbox.stub componentManager, '_onActiveInstanceChange'
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.CHANGE, changeSpy
        componentManager._activeInstancesCollection.trigger 'change', new Backbone.Model()
        assert changeSpy.called

      it 'should proxy remove events from the _activeInstancesCollection (EVENTS.REMOVE)', ->
        removeSpy = sandbox.spy()
        sandbox.stub componentManager, '_onActiveInstanceRemoved'
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.REMOVE, removeSpy
        componentManager._activeInstancesCollection.trigger 'remove', new Backbone.Model(), componentManager._activeInstancesCollection
        assert removeSpy.called

      it 'should return the componentManager for chainability', ->
        cm = componentManager.addListeners()
        assert.equal cm, componentManager

    describe 'addConditions', ->
      it 'should register new conditions', ->
        do componentManager.initialize
        globalConditionsSetSpy = sandbox.spy componentManager._globalConditionsModel, 'set'
        conditions =
          foo: -> return false
          bar: -> return true

        componentManager.addConditions conditions
        assert globalConditionsSetSpy.calledWith conditions, silent: false
        assert.deepEqual componentManager._globalConditionsModel.attributes, conditions

      it 'should not remove old conditions', ->

        conditions =
          foo: false
          bar: true

        secondCondition =
          baz: 'qux'

        expectedResults =
          foo: false
          bar: true
          baz: 'qux'

        silent = true

        do componentManager.initialize
        componentManager.addConditions conditions, silent
        componentManager.addConditions secondCondition

        assert.deepEqual componentManager._globalConditionsModel.attributes, expectedResults

      it 'should update existing conditions', ->
        conditions =
          foo: false
          bar: true

        updatedCondition =
          foo: true

        expectedResults =
          foo: true
          bar: true

        do componentManager.initialize

        componentManager.addConditions conditions
        assert.deepEqual componentManager._globalConditionsModel.attributes, conditions

        componentManager.addConditions updatedCondition
        assert.deepEqual componentManager._globalConditionsModel.attributes, expectedResults

      it 'should throw an CONDITION.WRONG_FORMAT error if condition is not an object', ->
        conditionInWrongFormat = 'string'
        errorFn = -> componentManager.addConditions conditionInWrongFormat
        assert.throws (-> errorFn()), /condition has to be an object with key value pairs/

      it 'should return the componentManager for chainability', ->
        conditions =
          foo: -> return false
          bar: -> return true

        cm = componentManager.initialize().addConditions conditions
        assert.equal cm, componentManager

    describe 'addComponents', ->
      it 'should call set on _componentDefinitionsCollection with passed definitions and parse: true, validate: true and remove: false', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        do componentManager.initialize
        componentDefinitionsCollectionSetSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'set'

        componentManager.addComponents component

        assert componentDefinitionsCollectionSetSpy.calledWith component,
          parse: true
          validate: true
          remove: false

      it 'should be able to add an array of components', ->
        components = [
          {
            id: 'dummy-component',
            src: 'http://www.google.com',
          }
          {
            id: 'dummy-component2',
            src: 'http://www.wikipedia.com',
          }
        ]

        do componentManager.initialize
        assert.equal componentManager._componentDefinitionsCollection.toJSON().length, 0

        componentManager.addComponents components
        assert.equal componentManager._componentDefinitionsCollection.toJSON().length, 2

      it 'should return the componentManager for chainability', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        cm = componentManager.initialize().addComponents component
        assert.equal cm, componentManager

    describe 'addInstance', ->
      it 'should call set on _instanceDefinitionsCollection with passed definitions and parse: true, validate: true and remove: false', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        do componentManager.initialize
        instanceDefinitionsCollectionSetSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'set'

        componentManager.addInstances instance

        assert instanceDefinitionsCollectionSetSpy.calledWith instance,
          parse: true
          validate: true
          remove: false

      it 'should be able to add an array of instances', ->
        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
          }
        ]

        do componentManager.initialize
        assert.equal componentManager._instanceDefinitionsCollection.toJSON().length, 0

        componentManager.addInstances instances
        assert.equal componentManager._instanceDefinitionsCollection.toJSON().length, 2

      it 'should return the componentManager for chainability', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        cm = componentManager.initialize().addInstances instance
        assert.equal cm, componentManager

    describe 'updateComponents', ->
      it 'should call addComponents with passed componentDefinitions', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        do componentManager.initialize
        addComponentsSpy = sandbox.spy componentManager, 'addComponents'
        componentManager.updateComponents component
        assert addComponentsSpy.calledWith component

      it 'should update a specific component with new data', ->
        components = [
          {
            id: 'dummy-component',
            src: 'http://www.google.com',
          }
          {
            id: 'dummy-component2',
            src: 'http://www.wikipedia.com',
          }
        ]

        updatedComponent =
          id: 'dummy-component',
          src: 'http://www.wikipedia.com',

        do componentManager.initialize

        componentManager.addComponents components
        assert.equal componentManager._componentDefinitionsCollection.get('dummy-component').toJSON().src, 'http://www.google.com'

        componentManager.updateComponents updatedComponent
        assert.equal componentManager._componentDefinitionsCollection.get('dummy-component').toJSON().src, 'http://www.wikipedia.com'

      it 'should return the componentManager for chainability', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        cm = componentManager.initialize().updateComponents component
        assert.equal cm, componentManager


    describe 'updateInstances', ->
      it 'should call addInstances with passed instanceDefinitions', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        do componentManager.initialize
        addInstancesSpy = sandbox.spy componentManager, 'addInstances'
        componentManager.updateInstances instance
        assert addInstancesSpy.calledWith instance

      it 'should update a specific instance with new data', ->
        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
          }
        ]

        updatedInstance =
          id: 'dummy-instance',
          targetName: '.header',

        do componentManager.initialize

        componentManager.addInstances instances
        assert.equal componentManager._instanceDefinitionsCollection.get('dummy-instance').toJSON().targetName, 'body'

        componentManager.updateInstances updatedInstance
        assert.equal componentManager._instanceDefinitionsCollection.get('dummy-instance').toJSON().targetName, '.header'

      it 'should return the componentManager for chainability', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        cm = componentManager.initialize().updateInstances instance
        assert.equal cm, componentManager

    describe 'removeComponent', ->
      it 'should call remove on the _componentDefinitionsCollection with passed componentDefinitionId', ->
        componentId = 'dummy-component'
        do componentManager.initialize
        removeComponentsSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'remove'
        componentManager.removeComponent componentId
        assert removeComponentsSpy.calledWith componentId

      it 'should remove a specific component', ->
        components = [
          {
            id: 'dummy-component',
            src: 'http://www.google.com',
          }
          {
            id: 'dummy-component2',
            src: 'http://www.wikipedia.com',
          }
        ]

        do componentManager.initialize
        componentManager.addComponents components

        assert.equal componentManager._componentDefinitionsCollection.length, 2
        componentManager.removeComponent components[0].id
        assert.equal componentManager._componentDefinitionsCollection.length, 1
        assert.equal componentManager._componentDefinitionsCollection.toJSON()[0].id, 'dummy-component2'

      it 'should return the componentManager for chainability', ->
        componentId = 'dummy-component'
        cm = componentManager.initialize().removeComponent componentId
        assert.equal cm, componentManager

    describe 'removeInstance', ->
      it 'should call remove on the _instanceDefinitionsCollection with passed instanceDefinitionId', ->
        instanceId = 'dummy-instance'
        do componentManager.initialize
        removeInstanceSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'remove'
        componentManager.removeInstance instanceId
        assert removeInstanceSpy.calledWith instanceId

      it 'should remove a specific instance', ->
        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
          }
        ]

        do componentManager.initialize
        componentManager.addInstances instances

        assert.equal componentManager._instanceDefinitionsCollection.length, 2
        componentManager.removeInstance instances[0].id
        assert.equal componentManager._instanceDefinitionsCollection.length, 1
        assert.equal componentManager._instanceDefinitionsCollection.toJSON()[0].id, 'dummy-instance2'

      it 'should return the componentManager for chainability', ->
        instanceId = 'dummy-instance'
        cm = componentManager.initialize().removeInstance instanceId
        assert.equal cm, componentManager

    describe 'removeListeners', ->
      it 'should call off on used collections and models', ->
        do componentManager.initialize

        activeInstancesCollectionOffSpy = sandbox.spy componentManager._activeInstancesCollection, 'off'
        filterModelOffSpy = sandbox.spy componentManager._filterModel, 'off'
        instanceDefinitionsCollectionOffSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'off'
        componentdefinitionsCollectionOffSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'off'
        globalConditionsModelOffSpy = sandbox.spy componentManager._globalConditionsModel, 'off'

        do componentManager.removeListeners

        assert activeInstancesCollectionOffSpy.called
        assert filterModelOffSpy.called
        assert instanceDefinitionsCollectionOffSpy.called
        assert componentdefinitionsCollectionOffSpy.called
        assert globalConditionsModelOffSpy.called

      it 'should return the componentManager for chainability', ->
        cm = componentManager.removeListeners()
        assert.equal cm, componentManager

    describe 'setContext', ->
      it 'should save the passed context', ->
        $context = $('<div/>')
        componentManager.setContext $context
        assert.equal componentManager._$context, $context

      it 'should save the passed context as a jQuery object if passing a string (using the string as a selector)', ->
        $context = '.test'
        componentManager.setContext $context
        assert.deepEqual componentManager._$context, $('.test')

      it 'should return the componentManager for chainability', ->
        cm = componentManager.setContext()
        assert.equal cm, componentManager

    describe 'setComponentClassName', ->
      it 'should save the componentClassName', ->
        componentClassName = 'dummy-class-name'
        componentManager.setComponentClassName componentClassName
        assert.equal componentManager._componentClassName, componentClassName

      it 'should use default componentClassName if method is called without passing a new name', ->
        componentClassName = 'dummy-class-name'
        componentManager.setComponentClassName componentClassName
        assert.equal componentManager._componentClassName, componentClassName

        do componentManager.setComponentClassName
        assert.equal componentManager._componentClassName, 'vigor-component'

      it 'should return the componentManager for chainability', ->
        cm = componentManager.setComponentClassName()
        assert.equal cm, componentManager

    describe 'setTargetPrefix', ->
      it 'should store the target prefix', ->
        targetPrefix = 'dummy-prefix'
        componentManager.setTargetPrefix targetPrefix
        assert.equal componentManager._targetPrefix, targetPrefix

      it 'should use default target prefix if method is called without passing a new prefix', ->
        targetPrefix = 'dummy-prefix'
        componentManager.setTargetPrefix targetPrefix
        assert.equal componentManager._targetPrefix, targetPrefix

        do componentManager.setTargetPrefix
        assert.equal componentManager._targetPrefix, 'component-area'

      it 'should return the componentManager for chainability', ->
        cm = componentManager.setTargetPrefix()
        assert.equal cm, componentManager

    describe 'getContext', ->
      it 'should return the context', ->
        $context = $('<div/>')
        componentManager.setContext $context
        result = componentManager.getContext()
        assert.equal result, $context

    describe 'getComponentClassName', ->
      it 'should return the componentClassName', ->
        componentClassName = 'dummy-class-name'
        componentManager.setComponentClassName componentClassName
        result = componentManager.getComponentClassName()
        assert.equal result, componentClassName

    describe 'getTargetPrefix', ->
      it 'should return a specified prefix or the default prefix', ->
        targetPrefix = 'dummy-prefix'
        componentManager.setTargetPrefix targetPrefix
        result = componentManager.getTargetPrefix()
        assert.equal result, targetPrefix

    describe 'getActiveFilter', ->
      it 'should return currently applied filters', ->
        do componentManager.initialize

        activeFilter =
          url: 'foo/bar'
          includeIfStringMatches: 'baz'

        expectedResults =
          url: 'foo/bar'
          includeIfStringMatches: 'baz'
          hasToMatchString: undefined
          cantMatchString: undefined

        componentManager.refresh activeFilter
        result = componentManager.getActiveFilter()

        assert.deepEqual result, expectedResults

    describe 'getConditions', ->
      it 'return current conditions', ->
        do componentManager.initialize

        globalCondition =
          foo: false
          bar: true

        componentManager.addConditions globalCondition

        result = componentManager.getConditions()

        assert.deepEqual result, globalCondition

    describe 'getComponentById', ->
      it 'should get a JSON representation of the data for a specific component', ->
        do componentManager.initialize

        components = [
          {
            id: 'dummy-component'
            src: 'http://www.google.com'
          }
          {
            id: 'dummy-component2'
            src: 'http://www.wikipedia.com'
          }
        ]

        expectedResultId = 'dummy-component'

        do componentManager.initialize

        componentManager.addComponents components
        result = componentManager.getComponentById 'dummy-component'

        assert.equal result.id, expectedResultId

    describe 'getInstanceById', ->
      it 'should get a JSON representation of the data for one specific instance', ->
        do componentManager.initialize

        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
          }
        ]

        do componentManager.initialize

        expectedResultId = 'dummy-instance'

        componentManager.addInstances instances
        result = componentManager.getInstanceById 'dummy-instance'

        assert.equal result.id, expectedResultId

    describe 'getComponents', ->
      it 'should return an array of all registered components', ->
        do componentManager.initialize

        components = [
          {
            id: 'dummy-component'
            src: 'http://www.google.com'
          }
          {
            id: 'dummy-component2'
            src: 'http://www.wikipedia.com'
          }
        ]

        expectedResultsIds = ['dummy-component', 'dummy-component2']

        componentManager.addComponents components
        results = componentManager.getComponents()

        assert.equal results.length, 2

        for result, i in results
          assert.equal result.id, expectedResultsIds[i]

    describe 'getInstances', ->
      it 'should return all instances (even those not currently active)', ->
        do componentManager.initialize

        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
          }
        ]

        expectedResultsIds = ['dummy-instance', 'dummy-instance2']

        componentManager.addInstances instances
        results = componentManager.getInstances()

        assert.equal results.length, 2

        for result, i in results
          assert.equal result.id, expectedResultsIds[i]

    describe 'getActiveInstances', ->
      it 'should return all instances that mataches the current filter', ->
        do componentManager.initialize

        activeFilter =
          url: 'foo/bar'

        components = [
          {
            id: 'dummy-component'
            src: 'http://www.google.com'
          }
          {
            id: 'dummy-component2'
            src: 'http://www.wikipedia.com'
          }
        ]

        instances = [
          {
            id: 'dummy-instance',
            componentId: 'dummy-component',
            targetName: 'body'
            urlPattern: 'foo/:id'
          }
          {
            id: 'dummy-instance2',
            componentId: 'dummy-component2',
            targetName: 'body'
            urlPattern: 'bar/:id'
          }
        ]

        componentManager.addComponents components
                        .addInstances instances

        componentManager.refresh activeFilter

        results = componentManager.getActiveInstances()

        assert.equal results.length, 1
        assert.equal results[0].src, 'http://www.google.com'
        assert.equal results[0].constructor.prototype.tagName, 'iframe'
        assert.equal results[0].constructor.prototype.className, 'vigor-component--iframe'

  # Private methods
  ##############################################################################
  describe 'private methods', ->
    describe '_parse', ->
      parseComponentSettingsStub = undefined

      beforeEach ->
        $('body').append '<div class="test"></div>'
        parseComponentSettingsStub = sandbox.stub componentManager, '_parseComponentSettings'

      afterEach ->
        do $('.test').remove

      it 'should call setContext and pass the $context from the passed settings (if it is defined)', ->
        $test = $('.test')

        settings =
          $context: $test

        setContextSpy = sandbox.spy componentManager, 'setContext'

        componentManager._parse settings
        assert setContextSpy.calledWith $test


      it 'should call setContext and pass body as a jquery object $("body") if no $context is defined in the passed settings', ->
        $body = $('body')

        settings =
          someOtherSettings: 'something not related to setContext'

        setContextSpy = sandbox.spy componentManager, 'setContext'

        componentManager._parse settings
        assert setContextSpy.calledWith $body

      it 'should call setComponentClassName with the componentClassName from the passed settings (if it is defined)', ->

        componentClassName = 'dummy-component-class-name'

        settings =
          componentClassName: componentClassName

        setComponentClassNameSpy = sandbox.spy componentManager, 'setComponentClassName'

        componentManager._parse settings
        assert setComponentClassNameSpy.calledWith componentClassName

      it 'should not call setComponentClassName if componentClassName is not defined in the settings object', ->
        settings =
          someOtherSettings: 'something not related to setComponentClassName'

        setComponentClassNameSpy = sandbox.spy componentManager, 'setComponentClassName'

        componentManager._parse settings
        assert.equal setComponentClassNameSpy.called, false

      it 'should call setTargetPrefix with the targetPrefix from the passed settings (if it is defined)', ->
        targetPrefix = 'dummy-target-prefix'

        settings =
          targetPrefix: targetPrefix

        setTargetPrefixSpy = sandbox.spy componentManager, 'setTargetPrefix'

        componentManager._parse settings
        assert setTargetPrefixSpy.calledWith targetPrefix

      it 'should not setTargetPrefix if targetPrefix is not defined in the settings object', ->
        settings =
          someOtherSettings: 'something not related to setTargetPrefix'

        setTargetPrefixSpy = sandbox.spy componentManager, 'setTargetPrefix'

        componentManager._parse settings
        assert.equal setTargetPrefixSpy.called, false

      it 'should call _parseComponentSettings with the componentSettings from the passed settings (if it is defined)', ->
        componentSettings =
          components: [
            {
              id: "filter-condition-component",
              src: "app.components.FilterComponent"
            }
          ]

        settings =
          componentSettings: componentSettings

        componentManager._parse settings
        assert parseComponentSettingsStub.calledWith, componentSettings

      it 'should call _parseComponentSettings with settings if componentSettings is not defined in the settings object', ->
        settings =
          someOtherSettings: 'something not related to _parseComponentSettings'

        componentManager._parse settings
        assert parseComponentSettingsStub.calledWith settings

      it 'should return the componentManager for chainability', ->
        cm = componentManager._parse()
        assert.equal cm, componentManager

    describe '_parseComponentSettings', ->
      it 'should call addConditions with passed conditions and silent set to true, if conditions are defined (and is an object that is not empty) in the passed componentSettings object', ->
        addComponentsStub = sandbox.stub componentManager, 'addConditions'

        conditions =
          foo: true

        silent = true

        componentSettings =
          conditions: conditions

        componentManager._parseComponentSettings componentSettings

        assert addComponentsStub.calledWith conditions, silent

      it 'should not call addConditions if passed conditions is not an object', ->
        addComponentsStub = sandbox.stub componentManager, 'addConditions'

        componentSettings =
          conditions: 'string'

        componentManager._parseComponentSettings componentSettings

        assert.equal addComponentsStub.called, false

      it 'should not call addConditions if passed conditions is an empty object', ->
        addComponentsStub = sandbox.stub componentManager, 'addConditions'

        componentSettings =
          conditions: {}

        componentManager._parseComponentSettings componentSettings

        assert.equal addComponentsStub.called, false

      it 'should not call _registerComponentDefinitions if niether components, widgets or componentDefinitions are defined in componentSettings', ->
        registerComponentsStub = sandbox.stub componentManager, '_registerComponentDefinitions'
        componentSettings =
          someOtherSettings: 'something not related to _registerComponentDefinitions'

        componentManager._parseComponentSettings componentSettings
        assert.equal registerComponentsStub.called, false


      it 'should not call _registerInstanceDefinitions if niether layoutsArray, targets, instanceDefinitions, instances are defined in componentSettings', ->
        registerInstanceDefinitionsStub = sandbox.stub componentManager, '_registerInstanceDefinitions'
        componentSettings =
          someOtherSettings: 'something not related to _registerInstanceDefinitions'

        componentManager._parseComponentSettings componentSettings
        assert.equal registerInstanceDefinitionsStub.called, false

      describe 'should call _registerComponentDefinitions', ->
        registerComponentsStub = undefined
        components = [
            {
              id: "filter-condition-component",
              src: "app.components.FilterComponent"
            }
          ]

        beforeEach ->
          registerComponentsStub = sandbox.stub componentManager, '_registerComponentDefinitions'

        it 'if components are defined in the componentSettings object', ->
          componentSettings =
            components: components

          componentManager._parseComponentSettings componentSettings
          assert registerComponentsStub.calledWith components

        it 'or if widgets are defined in the componentSettings object', ->
          componentSettings =
            widgets: components

          componentManager._parseComponentSettings componentSettings
          assert registerComponentsStub.calledWith components

        it 'or if componentDefinitions are defined in the componentSettings object', ->
          componentSettings =
            componentDefinitions: components

          componentManager._parseComponentSettings componentSettings
          assert registerComponentsStub.calledWith components

      describe 'should call _registerInstanceDefinitions', ->
        registerInstanceDefinitionsStub = undefined
        instanceDefinitions = [
          {
            id: "instance-1",
            componentId: "dummy-component"
          }
        ]

        beforeEach ->
          registerInstanceDefinitionsStub = sandbox.stub componentManager, '_registerInstanceDefinitions'

        it 'if layoutsArray is defined in the componentSettings object', ->
          componentSettings =
            layoutsArray: instanceDefinitions

          componentManager._parseComponentSettings componentSettings
          assert registerInstanceDefinitionsStub.calledWith instanceDefinitions

        it 'or if targets are defined in the componentSettings object', ->
          componentSettings =
            targets: instanceDefinitions

          componentManager._parseComponentSettings componentSettings
          assert registerInstanceDefinitionsStub.calledWith instanceDefinitions

        it 'or if instanceDefinitions are defined in the componentSettings object', ->
          componentSettings =
            instanceDefinitions: instanceDefinitions

          componentManager._parseComponentSettings componentSettings
          assert registerInstanceDefinitionsStub.calledWith instanceDefinitions

        it 'or if instances are defined in the componentSettings object', ->
          componentSettings =
            instances: instanceDefinitions

          componentManager._parseComponentSettings componentSettings
          assert registerInstanceDefinitionsStub.calledWith instanceDefinitions

      it 'should return the componentManager for chainability', ->
        cm = componentManager._parseComponentSettings {}
        assert.equal cm, componentManager

    describe '_registerComponentDefinitions', ->
      componentDefinitionsCollectionSetStub = undefined
      components = [
          {
            id: "filter-condition-component",
            src: "app.components.FilterComponent"
          }
        ]

      beforeEach ->
        componentManager._componentDefinitionsCollection = new __testOnly.ComponentDefinitionsCollection()
        componentDefinitionsCollectionSetStub = sandbox.stub componentManager._componentDefinitionsCollection, 'set'

      it 'should call _componentDefinitionsCollection.set with passed componentDefinitions, validate: true, parse: true and silent: true', ->
        configOptions =
          validate: true
          parse: true
          silent: true

        componentManager._registerComponentDefinitions components

        assert componentDefinitionsCollectionSetStub.calledWith components, configOptions

      it 'should return the componentManager for chainability', ->
        cm = componentManager._registerComponentDefinitions components
        assert.equal cm, componentManager

    describe '_registerInstanceDefinitions', ->
      instanceDefinitionsCollectionSetStub = undefined
      instanceDefinitionsCollectionSetTargetPrefixStub = undefined
      instanceDefinitions = [
        {
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'
        }
        {
          id: 'dummy-instance2',
          componentId: 'dummy-component2',
          targetName: 'body'
        }
      ]

      beforeEach ->
        componentManager._instanceDefinitionsCollection = new __testOnly.InstanceDefinitionsCollection()
        instanceDefinitionsCollectionSetStub = sandbox.stub componentManager._instanceDefinitionsCollection, 'set'
        instanceDefinitionsCollectionSetTargetPrefixStub = sandbox.stub componentManager._instanceDefinitionsCollection, 'setTargetPrefix'

      it 'should call _instanceDefinitionsCollection.setTargetPrefix with componentManager._targetPrefix', ->
        configOptions =
          validate: true
          parse: true
          silent: true

        targetPrefix = componentManager.getTargetPrefix()
        componentManager._registerInstanceDefinitions instanceDefinitions

        assert instanceDefinitionsCollectionSetTargetPrefixStub.calledWith targetPrefix

      it 'should call _instanceDefinitionsCollection.set with passed instanceDefinitions, validate: true, parse: true and silent: true', ->
        configOptions =
          validate: true
          parse: true
          silent: true

        componentManager._registerInstanceDefinitions instanceDefinitions

        assert instanceDefinitionsCollectionSetStub.calledWith instanceDefinitions, configOptions

      it 'should return the componentManager for chainability', ->
        cm = componentManager._registerInstanceDefinitions instanceDefinitions
        assert.equal cm, componentManager

    describe '_previousElement', ->
      beforeEach ->
        $('body').append '<div id="dummy1" class="dummy-elements" data-order="1"></div>'
        $('body').append '<div id="dummy2" class="dummy-elements" data-order="2"></div>'
        $('body').append '<div id="dummy3" class="some-other-element"></div>'
        $('body').append '<div id="dummy4" class="dummy-elements" data-order="3"></div>'
        $('body').append '<div id="dummy5" class="dummy-elements" data-order="4"></div>'
        $('body').append '<div id="dummy6" class="dummy-elements" data-order="8"></div>'

      afterEach ->
        do $('.dummy-elements').remove
        do $('some-other-element').remove

      it 'should return previous element based on the data-order attribute', ->
        $startEl = $ '.dummy-elements[data-order="4"]'
        $targetEl = $ '.dummy-elements[data-order="3"]'

        $result = componentManager._previousElement $startEl, $startEl.data('order')
        resultId = $result.attr 'id'
        targetId = $targetEl.attr 'id'

        assert.equal resultId, targetId

      it 'should find the previous element even though the order is not strictly sequential', ->
        $startEl = $ '.dummy-elements[data-order="8"]'
        $targetEl = $ '.dummy-elements[data-order="4"]'

        $result = componentManager._previousElement $startEl, $startEl.data('order')
        resultId = $result.attr 'id'
        targetId = $targetEl.attr 'id'

        assert.equal resultId, targetId

      it 'should skip elements without a data-order attribute', ->
        $startEl = $ '.dummy-elements[data-order="3"]'
        $targetEl = $ '.dummy-elements[data-order="2"]'

        $result = componentManager._previousElement $startEl, $startEl.data('order')
        resultId = $result.attr 'id'
        targetId = $targetEl.attr 'id'

        assert.equal resultId, targetId

      it 'should return undefined if there is $el.length is 0', ->
        $startEl = $ '.non-existing-element'
        $result = componentManager._previousElement $startEl, $startEl.data('order')

        assert.equal $result, undefined

      it 'should return undefined if no previous element can be found', ->
        $startEl = $ '.dummy-elements[data-order="1"]'
        $result = componentManager._previousElement $startEl, $startEl.data('order')

        assert.equal $result, undefined

    describe '_updateActiveComponents', ->
      it 'should call _filterInstanceDefinitions and pass current filters as json', ->
        do componentManager.initialize
        filterInstanceDefinitionsStub = sandbox.stub componentManager, '_filterInstanceDefinitions'
        filter =
          url: 'foo/bar'

        componentManager.refresh filter
        activeFilter = componentManager.getActiveFilter()

        do componentManager._updateActiveComponents
        assert filterInstanceDefinitionsStub.calledWith activeFilter

      it 'should call set with filtered instanceDefinitions on the _activeInstancesCollection', ->
        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header'
              urlPattern: 'foo/:id'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'test-prefix--main'
              urlPattern: 'bar/:id'
            }
          ]

        componentManager.initialize componentSettings
        activeInstancesCollectionSetSpy = sandbox.stub componentManager._activeInstancesCollection, 'set'

        expectedInstanceDefinition = componentManager._instanceDefinitionsCollection.get('instance-1')
        expectedInstanceDefinitions = [expectedInstanceDefinition]

        filter =
          url: 'foo/bar'

        componentManager.refresh filter

        do componentManager._updateActiveComponents
        assert activeInstancesCollectionSetSpy.calledWith expectedInstanceDefinitions

      it 'should call _tryToReAddStraysToDom', ->
        do componentManager.initialize
        tryToReAddStraysToDomStub = sandbox.stub componentManager, '_tryToReAddStraysToDom'

        do componentManager._updateActiveComponents
        assert tryToReAddStraysToDomStub.called

      it 'should return the componentManager for chainability', ->
        do componentManager.initialize
        cm = componentManager._updateActiveComponents()
        assert.equal cm, componentManager

    describe '_filterInstanceDefinitions', ->
      globalConditions =
        testCondition: false

      filterOptions =
        url: 'foo/bar'
        includeIfStringMatches: undefined
        hasToMatchString: undefined
        cantMatchString: undefined

      componentSettings =
        conditions: globalConditions
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header',
            urlPattern: 'foo/:id'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'test-prefix--main',
            urlPattern: 'bar/:id'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should call _instanceDefinitionsCollection.getInstanceDefinitions with filterOptions and globalConditions', ->
        getInstanceDefinitionsStub = sandbox.stub componentManager._instanceDefinitionsCollection, 'getInstanceDefinitions'
        componentManager._filterInstanceDefinitions filterOptions
        assert getInstanceDefinitionsStub.calledWith filterOptions, globalConditions

      it 'should call _filterInstanceDefinitionsByShowCount with the filterDefinitions that was returned by _instanceDefinitionsCollection.getInstanceDefinitions', ->
        expectedInstanceDefinitionId = 'instance-1'
        filterInstanceDefinitionsByShowCountStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByShowCount'
        componentManager._filterInstanceDefinitions filterOptions

        assert filterInstanceDefinitionsByShowCountStub.called
        assert.equal filterInstanceDefinitionsByShowCountStub.args[0][0].length, 1
        assert.equal filterInstanceDefinitionsByShowCountStub.args[0][0][0].attributes.id, expectedInstanceDefinitionId

      it 'should call _filterInstanceDefinitionsByConditions with the filterDefinitions that was returned by _filterInstanceDefinitionsByShowCount', ->
        expectedInstanceDefinitionId = 'instance-1'
        filterInstanceDefinitionsByComponentConditionsStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByConditions'
        componentManager._filterInstanceDefinitions filterOptions

        assert filterInstanceDefinitionsByComponentConditionsStub.called
        assert.equal filterInstanceDefinitionsByComponentConditionsStub.args[0][0].length, 1
        assert.equal filterInstanceDefinitionsByComponentConditionsStub.args[0][0][0].attributes.id, expectedInstanceDefinitionId

      it 'should return remaining instanceDefinitions after all previous filters', ->
        expectedInstanceDefinitionId = 'instance-1'
        result = componentManager._filterInstanceDefinitions filterOptions

        assert.equal result.length, 1
        assert.equal result[0].attributes.id, expectedInstanceDefinitionId

    describe '_filterInstanceDefinitionsByShowCount', ->
      it 'should return instanceDefinitions that does not exceed their showCount if they have a maxShowCount defined in their componentDefinition', ->
        expectedInstanceDefinitionId = 'instance-2'
        componentMaxShowCount = 3
        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent',
              maxShowCount: componentMaxShowCount
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header',
              showCount: 4
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'test-prefix--main',
              showCount: 1
            }
          ]

        componentManager.initialize componentSettings

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models

        exceedsMaximumShowCountSpies = []
        for instance in instanceDefinitions
          exceedsMaximumShowCountSpies.push sandbox.spy(instance, 'exceedsMaximumShowCount')

        assert.equal instanceDefinitions.length, 2

        instanceDefinitions = componentManager._filterInstanceDefinitionsByShowCount instanceDefinitions

        assert exceedsMaximumShowCountSpies[0].calledWith componentMaxShowCount
        assert exceedsMaximumShowCountSpies[1].calledWith componentMaxShowCount

        assert.equal instanceDefinitions.length, 1
        assert.equal instanceDefinitions[0].attributes.id, expectedInstanceDefinitionId

    describe '_filterInstanceDefinitionsByConditions', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent',
            conditions: []
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header',
            showCount: 4
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'test-prefix--main',
            showCount: 1
          }
        ]


      it 'should return instanceDefinitions that passes componentConditions if they are defined', ->
        componentManager.initialize componentSettings
        condition = ->
          currentTime = 8
          allowedTime = 4
          fancySucceedingTimeCheck = currentTime > allowedTime
          return fancySucceedingTimeCheck

        componentManager._componentDefinitionsCollection.models[0].attributes.conditions.push condition
        areConditionsMetSpy = sandbox.spy componentManager._componentDefinitionsCollection.models[0], 'areConditionsMet'

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 2

        instanceDefinitions = componentManager._filterInstanceDefinitionsByConditions instanceDefinitions

        assert areConditionsMetSpy.calledTwice
        assert.equal instanceDefinitions.length, 2

      it 'should not return instanceDefinitions that does not pass componentConditions if they are defined', ->
        componentManager.initialize componentSettings
        condition = ->
          currentTime = 2
          allowedTime = 4
          fancyFailingTimeCheck = currentTime > allowedTime
          return fancyFailingTimeCheck

        componentManager._componentDefinitionsCollection.models[0].attributes.conditions.push condition
        areConditionsMetSpy = sandbox.spy componentManager._componentDefinitionsCollection.models[0], 'areConditionsMet'

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 2

        instanceDefinitions = componentManager._filterInstanceDefinitionsByConditions instanceDefinitions

        assert areConditionsMetSpy.calledTwice
        assert.equal instanceDefinitions.length, 0

      it 'should use global conditions if a string referenced is defined as condition in the condition model', ->
        componentManager.initialize componentSettings
        condition =
          timeCheck: ->
            currentTime = 2
            allowedTime = 4
            fancyFailingTimeCheck = currentTime > allowedTime
            return fancyFailingTimeCheck

        # Register the condition as a global condition
        componentManager.addConditions condition

        # Reference the global condition key
        componentManager._componentDefinitionsCollection.models[0].attributes.conditions = ['timeCheck']

        areConditionsMetSpy = sandbox.spy componentManager._componentDefinitionsCollection.models[0], 'areConditionsMet'

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 2

        instanceDefinitions = componentManager._filterInstanceDefinitionsByConditions instanceDefinitions

        assert areConditionsMetSpy.calledTwice
        assert.equal instanceDefinitions.length, 0

    describe '_getInstanceHeight', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header'
          }
        ]

      height = 400

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should return height defined on a component level if the height on an instance level is not defined', ->
        componentManager._componentDefinitionsCollection.models[0].attributes.height = height
        componentManager._instanceDefinitionsCollection.models[0].attributes.height = undefined
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._getInstanceHeight instanceDefinition
        assert.equal result, height

      it 'should return height defined on an instance level if it is defined', ->
        componentManager._componentDefinitionsCollection.models[0].attributes.height = undefined
        componentManager._instanceDefinitionsCollection.models[0].attributes.height = height
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._getInstanceHeight instanceDefinition
        assert.equal result, height

      it 'should return undefined if the height is niether defined on an component level or on an instance level', ->
        componentManager._componentDefinitionsCollection.models[0].attributes.height = undefined
        componentManager._instanceDefinitionsCollection.models[0].attributes.height = undefined
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._getInstanceHeight instanceDefinition
        assert.equal result, undefined

    describe '_getInstanceArguments', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
          {
            id: 'mock-iframe-component',
            src: 'http://www.github.com'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header'
            urlPattern: 'foo/:bar'
          }
          {
            id: 'instance-2',
            componentId: 'mock-iframe-component',
            targetName: 'test-prefix--header'
            urlPattern: 'bar/:foo'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should add urlParams as an attribute on the args object', ->
        urlParams =
          bar: '123'
          url: 'foo/123'

        filter =
          url: 'foo/123'

        componentManager.refresh filter
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._getInstanceArguments instanceDefinition
        assert.deepEqual result.urlParams, [urlParams]

      it 'should add urlParamsModel as an attribute on the args object', ->
        urlParams =
          bar: '123'
          url: 'foo/123'

        filter =
          url: 'foo/123'

        componentManager.refresh filter
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._getInstanceArguments instanceDefinition
        assert result.urlParamsModel instanceof Backbone.Model
        assert.deepEqual result.urlParamsModel.attributes, urlParams

      it 'should return arguments (args) defined on a component level', ->
        args =
          arg1: 1
          arg2: 2

        componentManager._componentDefinitionsCollection.models[0].attributes.args = args
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = undefined

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition
        assert.equal result.arg1, args.arg1
        assert.equal result.arg2, args.arg2

      it 'should return arguments (args) defined on a instance level', ->
        args =
          arg1: 1
          arg2: 2

        componentManager._componentDefinitionsCollection.models[0].attributes.args = undefined
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = args

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition
        assert.equal result.arg1, args.arg1
        assert.equal result.arg2, args.arg2

      it 'should add and merge iframeAttributes from both component and instance level if its defined on both', ->
        componentArgs =
          iframeAttributes:
            height: 300
            width: 200

        instanceArgs =
          iframeAttributes:
            height: 100
            border: 0

        expectedResults =
          iframeAttributes:
            height: 100
            width: 200
            border: 0

        componentManager._componentDefinitionsCollection.models[0].attributes.args = componentArgs
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = instanceArgs

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition

        assert.deepEqual result.iframeAttributes, expectedResults.iframeAttributes

      it 'should merge arguments (args) from both component level and instance level if both are defined', ->
        componentArgs =
          height: 300
          width: 200

        instanceArgs =
          randomNr: 1234
          iframeAttributes:
            height: 100
            border: 0

        expectedResults =
          height: 300
          width: 200
          randomNr: 1234
          urlParams: undefined
          iframeAttributes:
            height: 100
            border: 0

        componentManager._componentDefinitionsCollection.models[0].attributes.args = componentArgs
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = instanceArgs

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition
        # urlParamsModel has a generated id that might change and therefore is not suitable for testing
        # because of that its removed from the result (we need predictable results)
        delete result.urlParamsModel

        assert.deepEqual result, expectedResults

      it 'should add src as an attribute on the args object if its an IframeComponent', ->
        args =
          foo: 'bar'

        expectedResults =
          foo: 'bar'
          src: 'http://www.github.com'

        componentManager._componentDefinitionsCollection.models[1].attributes.args = args

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[1]

        result = componentManager._getInstanceArguments instanceDefinition

        assert.equal result.src, expectedResults.src

    describe '_addInstanceToModel', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header'
            urlPattern: 'foo/:bar'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should call getComponentClassByInstanceDefinition on the componentDefinitionsCollection to get the the component Class which to create an instance from', ->
        getComponentClassByInstanceDefinitionSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentClassByInstanceDefinition'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        componentManager._addInstanceToModel instanceDefinition

        assert getComponentClassByInstanceDefinitionSpy.calledWith instanceDefinition

      it 'should call _getInstanceArguments to get arguments to pass along when creating the instance', ->
        getInstanceArgumentsSpy = sandbox.spy componentManager, '_getInstanceArguments'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        componentManager._addInstanceToModel instanceDefinition

        assert getInstanceArgumentsSpy.calledWith instanceDefinition

      it 'should call getComponentClassName to get the common dom classname thats used for all components', ->
        getComponentClassNameSpy = sandbox.spy componentManager, 'getComponentClassName'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        componentManager._addInstanceToModel instanceDefinition

        assert getComponentClassNameSpy.calledOnce

      it 'should call _getInstanceHeight to get instance height if set (main use case is iframe components)', ->
        getInstanceHeightSpy = sandbox.spy componentManager, '_getInstanceHeight'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        componentManager._addInstanceToModel instanceDefinition

        assert getInstanceHeightSpy.calledWith instanceDefinition

      it 'it should create a new instance of the class defined in the componentDefinition and update the instanceDefinition with the instance', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        instanceDefinitionSetSpy = sandbox.spy instanceDefinition, 'set'

        componentManager._addInstanceToModel instanceDefinition

        instance = instanceDefinitionSetSpy.args[0][0].instance
        silentSetting = instanceDefinitionSetSpy.args[0][1]

        assert instanceDefinitionSetSpy.called
        assert instance instanceof window.MockComponent
        assert.equal silentSetting.silent, true

      it 'should add _componentClassName to instance.$el', ->
        # Default classname
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        instanceDefinitionSetSpy = sandbox.spy instanceDefinition, 'set'
        expectedClassName = componentManager.getComponentClassName()
        newComponentClassName = 'new-component-class-name'

        componentManager._addInstanceToModel instanceDefinition

        instance = instanceDefinitionSetSpy.args[0][0].instance

        assert instance.$el.hasClass(expectedClassName)

        # custom classname
        do instanceDefinitionSetSpy.reset
        componentManager.setComponentClassName newComponentClassName

        componentManager._addInstanceToModel instanceDefinition

        instance = instanceDefinitionSetSpy.args[0][0].instance

        assert instance.$el.hasClass(newComponentClassName)

      it 'if a height is defined it should add it to the instance.$el', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        instanceDefinition.set 'height', 200
        instanceDefinitionSetSpy = sandbox.spy instanceDefinition, 'set'

        componentManager._addInstanceToModel instanceDefinition

        instance = instanceDefinitionSetSpy.args[0][0].instance

        assert.equal instance.$el.get(0).style.height, '200px'

      it 'it should return the passed instanceDefinition', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        returnedInstanceDefinition = componentManager._addInstanceToModel instanceDefinition
        assert.equal instanceDefinition, returnedInstanceDefinition

    describe '_tryToReAddStraysToDom', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header'
            urlPattern: 'foo/:bar'
          }
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'test-prefix--footer'
            urlPattern: 'foo/:bar'
          }
        ]

      beforeEach ->
        $('body').append '<div class="test-prefix--header"></div>'
        componentManager.initialize componentSettings

      afterEach ->
        do $('.test-prefix--header').remove
        do $('.test-prefix--footer').remove

      it 'should call _activeInstancesCollection.getStrays', ->
        getStraysSpy = sandbox.spy componentManager._activeInstancesCollection, 'getStrays'
        do componentManager._tryToReAddStraysToDom
        assert getStraysSpy.called

      it 'should call _addInstanceToDom and pass the stray and render = false for each stray returnd by getStrays', ->
        filter =
          url: 'foo/bar'

        componentManager.refresh filter
        addInstancesToDomStub = sandbox.stub componentManager, '_addInstanceToDom'
        do componentManager._tryToReAddStraysToDom

        firstCallArgs = addInstancesToDomStub.args[0]

        assert addInstancesToDomStub.calledOnce
        assert.equal firstCallArgs[0].id, 'instance-2'
        assert.equal firstCallArgs[1], false

      it 'if the instance was added to dom and there is a delegateEvents method it should be called', ->
        filter =
          url: 'foo/bar'

        componentManager.refresh filter

        strays = componentManager._activeInstancesCollection.getStrays()
        $('body').append '<div class="test-prefix--footer"></div>'

        firstStray = strays[0]
        componentManager._addInstanceToModel firstStray
        instance = firstStray.get 'instance'
        delegateEventsSpy = sandbox.spy instance, 'delegateEvents'
        do componentManager._tryToReAddStraysToDom
        assert delegateEventsSpy.called

      it 'if the instance was not added to the dom it means that there was no target for this instance and therefore it should be disposed', ->
        filter =
          url: 'foo/bar'

        componentManager.refresh filter

        strays = componentManager._activeInstancesCollection.getStrays()
        firstStray = strays[0]

        disposeInstanceSpy = sandbox.spy firstStray, 'disposeInstance'
        do componentManager._tryToReAddStraysToDom
        assert disposeInstanceSpy.called

    describe '_addInstanceToDom', ->

      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: 'window.MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'test-prefix--header'
            urlPattern: 'foo/:bar'
          }
        ]

      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'
        componentManager.initialize componentSettings

      afterEach ->
        do $('.test-prefix--header').remove

      it 'should call renderInstance if passed render argument is truthy', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        componentManager._addInstanceToModel instanceDefinition
        renderInstanceSpy = sandbox.spy instanceDefinition, 'renderInstance'
        componentManager._addInstanceToDom instanceDefinition, render
        assert renderInstanceSpy.called

      it 'should not call renderInstance if passed render argument is falsy', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = false
        componentManager._addInstanceToModel instanceDefinition
        renderInstanceSpy = sandbox.spy instanceDefinition, 'renderInstance'
        componentManager._addInstanceToDom instanceDefinition, render
        assert.equal renderInstanceSpy.called, false

      it 'should not call _addInstanceInOrder and pass the instanceDefinition if there is not a target present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        do $('.test-prefix--header').remove
        addInstanceInOrderStub = sandbox.stub componentManager, '_addInstanceInOrder'
        componentManager._addInstanceToDom instanceDefinition, render
        assert.equal addInstanceInOrderStub.called, false

      it 'should call _addInstanceInOrder and pass the instanceDefinition if there is a target present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        addInstanceInOrderStub = sandbox.stub componentManager, '_addInstanceInOrder'
        componentManager._addInstanceToDom instanceDefinition, render
        assert addInstanceInOrderStub.calledWith instanceDefinition

      it 'should call _setComponentAreaPopulatedState and pass the $target if there is a target present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        do $('.test-prefix--header').remove
        render = true
        setComponentAreaHasComponentStateStub = sandbox.stub componentManager, '_setComponentAreaPopulatedState'
        componentManager._addInstanceToDom instanceDefinition, render

        assert.equal setComponentAreaHasComponentStateStub.called, false

      it 'should call _setComponentAreaPopulatedState and pass the $target if there is a target present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        $target = $ '.test-prefix--header'
        render = true
        sandbox.stub componentManager, '_addInstanceInOrder'
        setComponentAreaHasComponentStateStub = sandbox.stub componentManager, '_setComponentAreaPopulatedState'
        componentManager._addInstanceToDom instanceDefinition, render

        $passedTarget = setComponentAreaHasComponentStateStub.args[0][0]

        assert setComponentAreaHasComponentStateStub.called
        assert.equal $target.attr('id'), $passedTarget.attr('id')

      it 'should call instanceDefinition.isAttached()', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        componentManager._addInstanceToModel instanceDefinition
        isAttachedSpy = sandbox.spy instanceDefinition, 'isAttached'
        isAddedToDom = componentManager._addInstanceToDom instanceDefinition, render

        assert.equal isAttachedSpy.called, true

      it 'should return true if the instance is present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        componentManager._addInstanceToModel instanceDefinition
        isAttachedSpy = sandbox.spy instanceDefinition, 'isAttached'
        isAddedToDom = componentManager._addInstanceToDom instanceDefinition, render

        assert.equal isAttachedSpy.called, true
        assert.equal isAddedToDom, true
        assert.equal $('body').find('#test-header').length, 1

      it 'should return false if the instance is not present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        render = true
        componentManager._addInstanceToModel instanceDefinition
        isAttachedSpy = sandbox.spy instanceDefinition, 'isAttached'
        do $('.test-prefix--header').remove
        isAddedToDom = componentManager._addInstanceToDom instanceDefinition, render

        assert.equal isAttachedSpy.called, true
        assert.equal isAddedToDom, false
        assert.equal $('body').find('#test-header').length, 0

    describe '_addInstanceInOrder', ->
      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'

      afterEach ->
        do $('.test-prefix--header').remove

      describe 'should add elements in order', ->
        componentSettings = undefined
        beforeEach ->
          componentSettings =
            components: [
              {
                id: 'mock-component',
                src: 'window.MockComponent'
              }
            ]
            instances: [
              {
                id: 'instance-1',
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 1
                args:
                  id: 'instance-1'
              }
              {
                id: 'instance-2',
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 2
                args:
                  id: 'instance-2'
              }
              {
                id: 'instance-3',
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 5
                args:
                  id: 'instance-3'
              }
              {
                id: 'instance-4',
                componentId: 'mock-component',
                targetName: 'test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 7
                args:
                  id: 'instance-4'
              }
            ]

        it 'should add components with an order attribute in an ascending order', ->
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'

          assert.equal first, 'instance-1'
          assert.equal second, 'instance-2'
          assert.equal third, 'instance-3'
          assert.equal fourth, 'instance-4'

        it 'it should add components in an ascending order even though there are
        already elements without an order attribute in the dom (elements without
        an order attributes should be pushed to the bottom)', ->

          elements = '<div id="dummy1"></div>'
          elements += '<div id="dummy2"></div>'
          elements += '<div id="dummy3"></div>'

          $('.test-prefix--header').append elements
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'

          fifth = $children.eq(4).attr 'id'
          sixth = $children.eq(5).attr 'id'
          seventh = $children.eq(6).attr 'id'

          assert.equal first, 'instance-1'
          assert.equal second, 'instance-2'
          assert.equal third, 'instance-3'
          assert.equal fourth, 'instance-4'

          assert.equal fifth, 'dummy1'
          assert.equal sixth, 'dummy2'
          assert.equal seventh, 'dummy3'

        it 'it should add components in an ascending order even though there are
        already elements with an order attribute in the dom', ->

          elements = '<div id="dummy1" data-order="3"></div>'
          elements += '<div id="dummy2" data-order="4"></div>'
          elements += '<div id="dummy3" data-order="6"></div>'

          $('.test-prefix--header').append elements
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'
          fifth = $children.eq(4).attr 'id'
          sixth = $children.eq(5).attr 'id'
          seventh = $children.eq(6).attr 'id'

          assert.equal first, 'instance-1'
          assert.equal second, 'instance-2'
          assert.equal third, 'dummy1'
          assert.equal fourth, 'dummy2'
          assert.equal fifth, 'instance-3'
          assert.equal sixth, 'dummy3'
          assert.equal seventh, 'instance-4'

        it 'should add components with order set to "top" first - before any
        other elements', ->
          componentSettings.instances[2].order = 'top'
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'

          assert.equal first, 'instance-3'
          assert.equal second, 'instance-1'
          assert.equal third, 'instance-2'
          assert.equal fourth, 'instance-4'

        it 'should add components with order set to "bottom" last - after any
        other elements', ->
          componentSettings.instances[2].order = 'bottom'
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'

          assert.equal first, 'instance-1'
          assert.equal second, 'instance-2'
          assert.equal third, 'instance-4'
          assert.equal fourth, 'instance-3'

        it 'should add components without any order attribute last', ->
          componentSettings.instances[2].order = undefined
          componentManager.initialize componentSettings

          filter =
            url: 'foo/1'

          componentManager.refresh filter

          $target = $ '.test-prefix--header'
          $children = $target.children()

          first = $children.eq(0).attr 'id'
          second = $children.eq(1).attr 'id'
          third = $children.eq(2).attr 'id'
          fourth = $children.eq(3).attr 'id'

          assert.equal first, 'instance-1'
          assert.equal second, 'instance-2'
          assert.equal third, 'instance-4'
          assert.equal fourth, 'instance-3'

      it 'after adding instance $el to the dom it should verify that its present
      and if the instance has an onAddedToDom method it should be called', ->

        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header'
              urlPattern: 'foo/:bar'
              order: 1
              args:
                id: 'instance-1'
            }
          ]

        componentManager.initialize componentSettings

        filter =
          url: 'foo/1'

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        isAttachedSpy = sandbox.spy instanceDefinition, 'isAttached'
        onAddedToDomSpy = sandbox.spy MockComponent.prototype, 'onAddedToDom'

        componentManager.refresh filter

        assert isAttachedSpy.called
        assert onAddedToDomSpy.called

      it 'should return the componentManager for chainability', ->
        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: 'window.MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'test-prefix--header'
              urlPattern: 'foo/:bar'
              order: 1
              args:
                id: 'instance-1'
            }
          ]

        componentManager.initialize componentSettings
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        filter =
          url: 'foo/1'

        componentManager.refresh filter

        cm = componentManager._addInstanceInOrder instanceDefinition
        assert.equal cm, componentManager

    describe '_isComponentAreaPopulated', ->
      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'

      afterEach ->
        do $('.test-prefix--header').remove

      it 'should return true if passed element has children', ->
        $componentArea = $ '#test-header'
        $componentArea.append '<div class="dummy-component"></div>'
        isPopulated = componentManager._isComponentAreaPopulated $componentArea
        assert.equal isPopulated, true

      it 'should return false if passed element has no children', ->
        $componentArea = $ '#test-header'
        isPopulated = componentManager._isComponentAreaPopulated $componentArea
        assert.equal isPopulated, false

    describe '_setComponentAreaPopulatedState', ->
      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'

      afterEach ->
        do $('.test-prefix--header').remove

      it 'should add a --has-components variation class to the component area
        ex: component-area--has-components if it holds components', ->

        componentManager.setTargetPrefix 'test-prefix'
        $componentArea = $ '#test-header'
        $componentArea.append '<div class="vigor-component"></div>'

        componentManager._setComponentAreaPopulatedState $componentArea

        assert $componentArea.hasClass('test-prefix--has-components')


      it 'should remove the --has-components variation class to the component area
      does not hold any components', ->

        componentManager.setTargetPrefix 'test-prefix'
        $componentArea = $ '#test-header'

        componentManager._setComponentAreaPopulatedState $componentArea

        assert.equal $componentArea.hasClass('test-prefix--has-components'), false



  # Callbacks
  ##############################################################################
  describe 'callbacks', ->
    describe '_onActiveInstanceAdd', ->
      it 'should', ->

    describe '_onActiveInstanceChange', ->
      it 'should', ->

    describe '_onActiveInstanceRemoved', ->
      it 'should', ->

    describe '_onActiveInstanceOrderChange', ->
      it 'should', ->

    describe '_onActiveInstanceTargetNameChange', ->
      it 'should', ->
