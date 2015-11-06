assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../dist/vigor.componentmanager'

componentManager = new Vigor.ComponentManager()
__testOnly = Vigor.ComponentManager.__testOnly

MockComponent = require './MockComponent'
MockComponent2 = require './MockComponent2'

clock = undefined

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

        parseStub = sandbox.stub componentManager, '_parse'
        componentManager.updateSettings settings
        assert parseStub.calledWith settings

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

      it 'should call _updateActiveComponents and return the promise returned from
      _updateActiveComponents', ->
        do componentManager.initialize
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        result = do componentManager.refresh
        expectedResult = updateActiveComponentsSpy.returnValues[0]

        assert updateActiveComponentsSpy.called
        assert _.isFunction(result.then)
        assert.deepEqual result, expectedResult

    describe 'serialize', ->
      settings = undefined
      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'
        settings =
          context: '.test-prefix--header'
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
                src: '../test/spec/MockComponent'
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
        assert.equal parsed.context, settings.context
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
        context: $ '<div class="test"></div>'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: 'test-condition': false
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
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
        context: 'div.test'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: 'test-condition': false
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
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
          context: '.clear-test'
          targetPrefix: 'test-prefix'
          componentSettings:
            conditions: 'test-condition': false
            components: [
              {
                id: 'mock-component',
                src: '../test/spec/MockComponent'
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
        components = componentManager.getComponentDefinitions()
        assert.equal components.length, 1

        do componentManager.clear

        components = componentManager.getComponentDefinitions()
        assert.equal components.length, 0

      it 'should remove all instances', ->
        components = componentManager.getInstanceDefinitions()
        assert.equal components.length, 2

        do componentManager.clear

        components = componentManager.getInstanceDefinitions()
        assert.equal components.length, 0

      it 'should remove all activeComponents', ->
        componentManager.refresh
          url: 'foo/1'

        instances = componentManager.getActiveInstances()
        assert.equal instances.length, 1

        do componentManager.clear

        instances = componentManager.getInstanceDefinitions()
        assert.equal instances.length, 0

      it 'should remove all filters', ->
        componentManager.refresh
          url: 'foo/1'

        filter = componentManager.getActiveFilter()
        expectedResults =
          url: 'foo/1'
          filterString: undefined
          includeIfStringMatches: undefined
          excludeIfStringMatches: undefined
          hasToMatchString: undefined
          cantMatchString: undefined
          options:
            add: true
            remove: true
            merge: true
            invert: false
            forceFilterStringMatching: false

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

      it 'should add change listeners on these params on the _activeInstancesCollection: componentId, filterString, 
      conditions, args, showCount, urlPattern, urlParams, reInstantiateOnUrlParamChange with _onActiveInstanceChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceChangeStub = sandbox.stub componentManager, '_onActiveInstanceChange'

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
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:filterString', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:conditions', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:args', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:showCount', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:urlPattern', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:urlParams', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

        componentManager._activeInstancesCollection.trigger 'change:reInstantiateOnUrlParamChange', new Backbone.Model()
        assert onActiveInstanceChangeStub.called
        do onActiveInstanceChangeStub.reset

      it 'should add a change:order listener on the _activeInstancesCollection with _onActiveInstanceOrderChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceOrderStub = sandbox.stub componentManager, '_onActiveInstanceOrderChange'

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'change:order', componentManager._onActiveInstanceOrderChange

        componentManager._activeInstancesCollection.trigger 'change:order', new Backbone.Model()
        assert onActiveInstanceOrderStub.called

      it 'should add a change:targetName listener on the _activeInstancesCollection with
      _onActiveInstanceTargetNameChange as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        onActiveInstanceTargetNameChangeStub = sandbox.stub componentManager, '_onActiveInstanceTargetNameChange'

        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'change:targetName', componentManager._onActiveInstanceTargetNameChange

        componentManager._activeInstancesCollection.trigger 'change:targetName', new Backbone.Model()
        assert onActiveInstanceTargetNameChangeStub.called

      it 'should add a change:remove listener on the _activeInstancesCollection with
      _onActiveInstanceRemoved as callback', ->
        activeInstancesCollectionOnSpy = sandbox.spy componentManager._activeInstancesCollection, 'on'
        sandbox.stub componentManager, '_onActiveInstanceAdd', ->
        onActiveInstanceRemovedStub = sandbox.stub componentManager, '_onActiveInstanceRemoved'


        do componentManager.addListeners
        assert activeInstancesCollectionOnSpy.calledWith 'remove', componentManager._onActiveInstanceRemoved

        componentManager._activeInstancesCollection.add { id: 'dummy' }
        componentManager._activeInstancesCollection.remove 'dummy'
        assert onActiveInstanceRemovedStub.called

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

    describe 'addComponentDefinitions', ->
      it 'should call set on _componentDefinitionsCollection with passed definitions and parse: true, validate: true and remove: false', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        do componentManager.initialize
        componentDefinitionsCollectionSetSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'set'

        componentManager.addComponentDefinitions component

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

        componentManager.addComponentDefinitions components
        assert.equal componentManager._componentDefinitionsCollection.toJSON().length, 2

      it 'should return the componentManager for chainability', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        cm = componentManager.initialize().addComponentDefinitions component
        assert.equal cm, componentManager

    describe 'addInstanceDefinitions', ->
      it 'should call set on _instanceDefinitionsCollection with passed definitions and parse: true, validate: true and remove: false', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        do componentManager.initialize

        expectedResults =
          instanceDefinitions: instance
          targetPrefix: componentManager.getTargetPrefix()

        instanceDefinitionsCollectionSetSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'set'

        componentManager.addInstanceDefinitions instance

        assert instanceDefinitionsCollectionSetSpy.calledWith expectedResults,
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

        componentManager.addInstanceDefinitions instances
        assert.equal componentManager._instanceDefinitionsCollection.toJSON().length, 2

      it 'should return the componentManager for chainability', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        cm = componentManager.initialize().addInstanceDefinitions instance
        assert.equal cm, componentManager

    describe 'updateComponentDefinitions', ->
      it 'should call addComponentDefinitions with passed componentDefinitions', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        do componentManager.initialize
        addComponentsSpy = sandbox.spy componentManager, 'addComponentDefinitions'
        componentManager.updateComponentDefinitions component
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

        componentManager.addComponentDefinitions components
        assert.equal componentManager._componentDefinitionsCollection.get('dummy-component').toJSON().src, 'http://www.google.com'

        componentManager.updateComponentDefinitions updatedComponent
        assert.equal componentManager._componentDefinitionsCollection.get('dummy-component').toJSON().src, 'http://www.wikipedia.com'

      it 'should return the componentManager for chainability', ->
        component =
          id: 'dummy-component',
          src: 'http://www.google.com',

        cm = componentManager.initialize().updateComponentDefinitions component
        assert.equal cm, componentManager


    describe 'updateInstanceDefinitions', ->
      it 'should call addInstanceDefinitions with passed instanceDefinitions', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        do componentManager.initialize
        addInstancesSpy = sandbox.spy componentManager, 'addInstanceDefinitions'
        componentManager.updateInstanceDefinitions instance
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
          targetName: 'header',

        do componentManager.initialize

        componentManager.addInstanceDefinitions instances
        assert.equal componentManager._instanceDefinitionsCollection.get('dummy-instance').toJSON().targetName, 'body'

        componentManager.updateInstanceDefinitions updatedInstance
        assert.equal componentManager._instanceDefinitionsCollection.get('dummy-instance').toJSON().targetName, 'component-area--header'

      it 'should return the componentManager for chainability', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        cm = componentManager.initialize().updateInstanceDefinitions instance
        assert.equal cm, componentManager

    describe 'removeComponentDefinition', ->
      it 'should call remove on the _componentDefinitionsCollection with passed componentDefinitionId', ->
        componentId = 'dummy-component'
        do componentManager.initialize
        removeComponentsSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'remove'
        componentManager.removeComponentDefinition componentId
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
        componentManager.addComponentDefinitions components

        assert.equal componentManager._componentDefinitionsCollection.length, 2
        componentManager.removeComponentDefinition components[0].id
        assert.equal componentManager._componentDefinitionsCollection.length, 1
        assert.equal componentManager._componentDefinitionsCollection.toJSON()[0].id, 'dummy-component2'

      it 'should return the componentManager for chainability', ->
        componentId = 'dummy-component'
        cm = componentManager.initialize().removeComponentDefinition componentId
        assert.equal cm, componentManager

    describe 'removeInstanceDefinition', ->
      it 'should call remove on the _instanceDefinitionsCollection with passed instanceDefinitionId', ->
        instanceId = 'dummy-instance'
        do componentManager.initialize
        removeInstanceSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'remove'
        componentManager.removeInstanceDefinition instanceId
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
        componentManager.addInstanceDefinitions instances

        assert.equal componentManager._instanceDefinitionsCollection.length, 2
        componentManager.removeInstanceDefinition instances[0].id
        assert.equal componentManager._instanceDefinitionsCollection.length, 1
        assert.equal componentManager._instanceDefinitionsCollection.toJSON()[0].id, 'dummy-instance2'

      it 'should return the componentManager for chainability', ->
        instanceId = 'dummy-instance'
        cm = componentManager.initialize().removeInstanceDefinition instanceId
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
        $context = $ '<div/>'
        componentManager.setContext $context
        assert.equal componentManager._$context, $context

      it 'should default to using "body" if no argument is passed', ->
        $context = $ 'body'
        do componentManager.setContext
        assert.deepEqual componentManager._$context, $context

      it 'should save the passed context as a jQuery object if passing a string
      (using the string as a selector)', ->
        $context = '.test'
        componentManager.setContext $context
        assert.deepEqual componentManager._$context, $('.test')

      it 'should throw an CONTEXT.WRONG_FORMAT error if the passed context is not
      a jquery object or a string', ->
        errorFn = -> componentManager.setContext({})
        assert.throws (-> errorFn()), /context should be a string or a jquery object/

        errorFn = -> componentManager.setContext([])
        assert.throws (-> errorFn()), /context should be a string or a jquery object/

        errorFn = -> componentManager.setContext(1)
        assert.throws (-> errorFn()), /context should be a string or a jquery object/

      it 'should return the componentManager for chainability', ->
        cm = componentManager.setContext('.test')
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
          filterString: undefined
          includeIfStringMatches: 'baz'
          excludeIfStringMatches: undefined
          hasToMatchString: undefined
          cantMatchString: undefined
          options:
            add: true
            remove: true
            merge: true
            invert: false
            forceFilterStringMatching: false

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

    describe 'getComponentDefinitionById', ->
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

        componentManager.addComponentDefinitions components
        result = componentManager.getComponentDefinitionById 'dummy-component'

        assert.equal result.id, expectedResultId

    describe 'getInstanceDefinitionById', ->
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

        componentManager.addInstanceDefinitions instances
        result = componentManager.getInstanceDefinitionById 'dummy-instance'

        assert.equal result.id, expectedResultId

    describe 'getComponentDefinitions', ->
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

        componentManager.addComponentDefinitions components
        results = componentManager.getComponentDefinitions()

        assert.equal results.length, 2

        for result, i in results
          assert.equal result.id, expectedResultsIds[i]

    describe 'getInstanceDefinitions', ->
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

        componentManager.addInstanceDefinitions instances
        results = componentManager.getInstanceDefinitions()

        assert.equal results.length, 2

        for result, i in results
          assert.equal result.id, expectedResultsIds[i]

    describe 'getActiveInstances', ->
      it 'should call _mapInstances with _activeInstancesCollection.models and
      createNewInstancesIfUndefined set to false by default', ->

        componentSettings =
          components: [
            {
              id: 'dummy-component'
              src: 'http://www.google.com'
            }
            {
              id: 'dummy-component2'
              src: 'http://www.wikipedia.com'
            }
          ]

          instances: [
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

        mapInstancesSpy = sandbox.spy componentManager, '_mapInstances'
        componentManager.initialize componentSettings
        results = componentManager.getActiveInstances()
        assert mapInstancesSpy.calledWith componentManager._activeInstancesCollection.models, false


    describe 'getActiveInstanceById', ->
      componentSettings = undefined

      beforeEach ->
        $('body').append '<div class="component-area--header"></div>'
        settings =
          componentSettings:
            components: [
              {
                id: 'mock-component',
                src: '../test/spec/MockComponent'
              }
            ]
            instances: [
              {
                id: 'instance-1',
                componentId: 'mock-component',
                targetName: 'component-area--header'
                urlPattern: 'foo/:bar'
                order: 1
                args:
                  id: 'instance-1'
              }
            ]

        afterEach ->
          do $('.component-area--header').remove

        componentManager.initialize settings

      it 'should call _activeInstancesCollection.getInstanceDefinition with the passed id', ->
        getInstanceDefinitionStub = sandbox.stub componentManager._activeInstancesCollection, 'getInstanceDefinition'
        id = 'instance-1'
        componentManager.getActiveInstanceById id
        assert getInstanceDefinitionStub.calledWith(id)

      it 'should return the instance from the instanceDefinitionModel if it exists', ->
        getInstanceDefinitionSpy = sandbox.spy componentManager._activeInstancesCollection, 'getInstanceDefinition'
        id = 'instance-1'
        filter =
          url: 'foo/1'

        componentManager.refresh filter

        instance = componentManager.getActiveInstanceById id
        assert instance instanceof MockComponent

      it 'should return undefined if there is no instance in the targeted instanceDefinition', ->
        getInstanceDefinitionSpy = sandbox.spy componentManager._activeInstancesCollection, 'getInstanceDefinition'
        id = 'instance-1'
        filter =
          url: 'foo/1'

        componentManager.refresh filter

        do componentManager._activeInstancesCollection.at(0).disposeInstance
        instance = componentManager.getActiveInstanceById id
        assert.equal instance, undefined

    describe 'postMessageToInstance', ->
      componentSettings = undefined

      beforeEach ->
        $('body').append '<div class="test-prefix--header" id="test-header"></div>'
        settings =
          targetPrefix: 'test-prefix',
          componentSettings:
            components: [
              {
                id: 'mock-component',
                src: '../test/spec/MockComponent'
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

        filter =
          url: 'foo/1'

        componentManager.initialize settings
        componentManager.refresh filter

      it 'should throw a MISSING_ID error if no id was passed', ->
        errorFn = -> do componentManager.postMessageToInstance
        assert.throws (-> errorFn()), /The id of targeted instance must be passed as first argument/

        errorFn = -> do componentManager.postMessageToInstance undefined, 'this is my message '
        assert.throws (-> errorFn()), /The id of targeted instance must be passed as first argument/

      it 'should throw a MISSING_MESSAGE if no message was passed', ->
        id = 'instance-1'
        errorFn = -> componentManager.postMessageToInstance id
        assert.throws (-> errorFn()), /No message was passed/

      it 'should call receiveMessage and pass the message if it exist', ->
        id = 'instance-1'
        message = 'this is my message'
        instance = componentManager._activeInstancesCollection.get('instance-1').get 'instance'
        receiveMessageSpy = sandbox.spy instance, 'receiveMessage'
        componentManager.postMessageToInstance id, message
        assert receiveMessageSpy.calledWith message

      it 'should throw an MISSING_RECEIVE_MESSAGE_METHOD error if receiveMessage does not exist', ->
        id = 'instance-1'
        message = 'this is my message'
        instance = componentManager._activeInstancesCollection.get('instance-1').get 'instance'
        instance.receiveMessage = undefined
        errorFn = -> componentManager.postMessageToInstance id, message
        assert.throws (-> errorFn()), /The instance does not seem to have a receiveMessage method/


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

      it 'should call setContext and pass the context from the passed settings (if it is defined)', ->
        $test = $('.test')

        settings =
          context: $test

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

      it 'should call _instanceDefinitionsCollection.set with passed instanceDefinitions,
      validate: true, parse: true and silent: true', ->
        configOptions =
          validate: true
          parse: true
          silent: true

        expectedResults =
          instanceDefinitions: instanceDefinitions
          targetPrefix: componentManager.getTargetPrefix()

        componentManager._registerInstanceDefinitions instanceDefinitions
        assert instanceDefinitionsCollectionSetStub.calledWith expectedResults, configOptions

      it 'should return the componentManager for chainability', ->
        cm = componentManager._registerInstanceDefinitions instanceDefinitions
        assert.equal cm, componentManager

    describe '_updateActiveComponents', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
          },
          {
            id: 'mock-component2',
            src: '../test/spec/MockComponent2'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header'
            urlPattern: 'foo/:id'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component2',
            targetName: 'component-area--main'
            urlPattern: 'bar/:id'
          }
        ]

      beforeEach ->
        $('body').append '<div class="component-area--header"></div>'
        $('body').append '<div class="component-area--main"></div>'

      afterEach ->
        do $('.component-area--header').remove
        do $('.component-area--main').remove

      it 'should call getFilterOptions on the filterModel to get current
      filterOptions', ->
        componentManager.initialize componentSettings
        getFilterOptionsSpy = sandbox.spy componentManager._filterModel, 'getFilterOptions'
        do componentManager._updateActiveComponents
        assert getFilterOptionsSpy.called

      it 'should call _filterInstanceDefinitions', ->
        componentManager.initialize componentSettings
        filterInstanceDefinitionsSpy = sandbox.spy componentManager, '_filterInstanceDefinitions'

        do componentManager._updateActiveComponents
        assert filterInstanceDefinitionsSpy.called

      it 'should call set with filtered instanceDefinitions and options (from the filterModel)
      on the _activeInstancesCollection', ->
        componentManager.initialize componentSettings
        activeInstancesCollectionSetStub = sandbox.stub componentManager._activeInstancesCollection, 'set'

        instanceDefinition = componentManager._instanceDefinitionsCollection.at(0)
        expectedInstanceDefinitions = [instanceDefinition]

        options =
          add: true
          remove: false
          merge: false
          invert: false
          forceFilterStringMatching: false

        filter =
          url: 'foo/bar'
          options: options

        componentManager.refresh filter

        do componentManager._updateActiveComponents
        assert activeInstancesCollectionSetStub.calledWith expectedInstanceDefinitions, options

      it 'should call getComponentClassPromisesByInstanceDefinitions to get class promises
      for all active instanceDefinitions', ->
        componentManager.initialize componentSettings
        getComponentClassPromisesByInstanceDefinitionsSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentClassPromisesByInstanceDefinitions'

        do componentManager._updateActiveComponents
        promises = getComponentClassPromisesByInstanceDefinitionsSpy.returnValues[0]

        assert getComponentClassPromisesByInstanceDefinitionsSpy.called
        assert.equal promises.length, 2
        assert _.isFunction(promises[0].then)
        assert _.isFunction(promises[1].then)

        assert promises[0].then (componentClassObj) ->
          assert componentClassObj.componentDefinition is componentManager._componentDefinitionsCollection.get 'mock-component'
          assert componentClassObj.componentClass is MockComponent

        assert promises[1].then (componentClassObj) ->
          assert componentClassObj.componentDefinition is componentManager._componentDefinitionsCollection.get 'mock-component2'
          assert componentClassObj.componentClass is MockComponent2

      it 'should wait until all classes has been loaded and then resolve its own
      promise with an object containg active filter, active instances, active instanceDefinitions,
      last changed instancecs, and last changed instanceDefinitions', ->
        componentManager.initialize componentSettings
        getComponentClassPromisesByInstanceDefinitionsSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentClassPromisesByInstanceDefinitions'

        filter =
          url: 'foo/1'

        callback = sandbox.spy()

        componentManager._filterModel.set filter
        componentManager._updateActiveComponents().then callback

        args = callback.args[0][0]
        componentClassPromises = getComponentClassPromisesByInstanceDefinitionsSpy.returnValues[0]

        assert.equal componentClassPromises.length, 1
        assert.equal componentClassPromises[0].state(), 'resolved'

        assert getComponentClassPromisesByInstanceDefinitionsSpy.called
        assert callback.called

        # .filter
        assert.equal args.filter.url, filter.url
        assert.deepEqual args.filter, componentManager._filterModel.toJSON()

        # .activeInstances
        assert.equal args.activeInstances.length, 1
        assert args.activeInstances[0] instanceof MockComponent

        # .activeInstanceDefinitions
        assert.equal args.activeInstanceDefinitions.length, 1
        assert.equal args.activeInstanceDefinitions[0].id, 'instance-1'

        # .lastChangedInstances
        assert.equal args.lastChangedInstances.length, 1
        assert args.lastChangedInstances[0] instanceof MockComponent

        # .lastChangedInstanceDefinitions
        assert.equal args.lastChangedInstanceDefinitions.length, 1
        assert.equal args.lastChangedInstanceDefinitions[0].id, 'instance-1'

      it 'should resolve its promise with instances NOT matching the filter if options.invert
      is set to true', ->
        componentManager.initialize componentSettings
        filter =
          url: 'foo/bar'
          options:
            invert: true

        componentManager._filterModel.set filter

        callback = sandbox.spy()
        componentManager._updateActiveComponents().then callback
        args = callback.args[0][0]

        # filter
        assert.deepEqual args.filter.url, filter.url
        assert.deepEqual args.filter.options.invert, filter.options.invert
        assert.deepEqual args.filter, componentManager._filterModel.toJSON()

        # .activeInstances
        assert.equal args.activeInstances.length, 1
        assert args.activeInstances[0] instanceof MockComponent2

        # .activeInstanceDefinitions
        assert.equal args.activeInstanceDefinitions.length, 1
        assert.equal args.activeInstanceDefinitions[0].id, 'instance-2'

        # .lastChangedInstances
        assert.equal args.lastChangedInstances.length, 1
        assert args.lastChangedInstances[0] instanceof MockComponent2

        # # .lastChangedInstanceDefinitions
        assert.equal args.lastChangedInstanceDefinitions.length, 1
        assert.equal args.lastChangedInstanceDefinitions[0].id, 'instance-2'

      it 'should resolve promise with all active instances and the last changed/added instances -
      and they might not allways be the same depending on the provided options', ->

        componentManager.initialize componentSettings
        instanceDefinitionOne = componentManager._instanceDefinitionsCollection.get 'instance-1'
        instanceDefinitionTwo = componentManager._instanceDefinitionsCollection.get 'instance-2'

        filter =
          url: 'foo/bar'

        componentManager._filterModel.set filter
        componentManager._updateActiveComponents()

        filter =
          url: 'bar/foo'
          options:
            remove: false

        componentManager._filterModel.set filter

        callback = sandbox.spy()
        componentManager._updateActiveComponents().then callback
        args = callback.args[0][0]

        # filter
        assert.deepEqual args.filter.url, filter.url
        assert.deepEqual args.filter.options.remove, filter.options.remove
        assert.deepEqual args.filter, componentManager._filterModel.toJSON()

        # .activeInstances
        assert.equal args.activeInstances.length, 2
        assert args.activeInstances[0] instanceof MockComponent
        assert args.activeInstances[1] instanceof MockComponent2

        # .activeInstanceDefinitions
        assert.equal args.activeInstanceDefinitions.length, 2
        assert.equal args.activeInstanceDefinitions[0].id, 'instance-1'
        assert.equal args.activeInstanceDefinitions[1].id, 'instance-2'

        # .lastChangedInstances
        assert.equal args.lastChangedInstances.length, 1
        assert args.lastChangedInstances[0] instanceof MockComponent2

        # # .lastChangedInstanceDefinitions
        assert.equal args.lastChangedInstanceDefinitions.length, 1
        assert.equal args.lastChangedInstanceDefinitions[0].id, 'instance-2'

      it 'should call _tryToReAddStraysToDom after all classes has been loaded', ->
        componentManager.initialize componentSettings
        tryToReAddStraysToDomStub = sandbox.stub componentManager, '_tryToReAddStraysToDom'
        getComponentClassPromisesByInstanceDefinitionsSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentClassPromisesByInstanceDefinitions'

        do componentManager._updateActiveComponents
        componentClassPromises = getComponentClassPromisesByInstanceDefinitionsSpy.returnValues[0]

        assert.equal componentClassPromises.length, 2
        assert.equal componentClassPromises[0].state(), 'resolved'
        assert.equal componentClassPromises[1].state(), 'resolved'
        assert tryToReAddStraysToDomStub.called

      it 'should return a promise', ->
        do componentManager.initialize
        result = do componentManager._updateActiveComponents
        assert _.isFunction(result.then)

    describe '_filterInstanceDefinitions', ->
      globalConditions =
        testCondition: false

      filterModel = undefined

      componentSettings =
        conditions: globalConditions
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header',
            urlPattern: 'foo/:id'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'component-area--main',
            urlPattern: 'bar/:id'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings
        componentManager.refresh url: 'foo/bar'
        filterModel = componentManager._filterModel

        $('body').append '<div class="component-area--header"></div>'
        $('body').append '<div class="component-area--main"></div>'

      afterEach ->
        do $('.component-area--header').remove
        do $('.component-area--main').remove

      it 'should call _instanceDefinitionsCollection.filterInstanceDefinitions
      with the filterModel and globalConditions', ->
        filterInstanceDefinitionsStub = sandbox.stub componentManager._instanceDefinitionsCollection, 'filterInstanceDefinitions'
        do componentManager._filterInstanceDefinitions
        assert filterInstanceDefinitionsStub.calledWith filterModel, globalConditions

      it 'should call _filterInstanceDefinitionsByShowCount with the filterDefinitions
      that was returned by _instanceDefinitionsCollection.filterInstanceDefinitions', ->
        expectedInstanceDefinitionId = 'instance-1'
        filterInstanceDefinitionsByShowCountStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByShowCount'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByShowCountStub.called
        assert.equal filterInstanceDefinitionsByShowCountStub.args[0][0].length, 1
        assert.equal filterInstanceDefinitionsByShowCountStub.args[0][0][0].attributes.id, expectedInstanceDefinitionId

      it 'should call _filterInstanceDefinitionsByConditions with the filterDefinitions
      that was returned by _filterInstanceDefinitionsByShowCount', ->
        expectedInstanceDefinitionId = 'instance-1'
        filterInstanceDefinitionsByConditionsStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByConditions'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByConditionsStub.called
        assert.equal filterInstanceDefinitionsByConditionsStub.args[0][0].length, 1
        assert.equal filterInstanceDefinitionsByConditionsStub.args[0][0][0].attributes.id, expectedInstanceDefinitionId

      it 'should call _filterInstanceDefinitionsByTargetAvailability with the filterDefinitions
      that was returned by _filterInstanceDefinitionsByConditions', ->
        expectedInstanceDefinitionId = 'instance-1'
        filterInstanceDefinitionsByTargetAvailabilityStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByTargetAvailability'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByTargetAvailabilityStub.called
        assert.equal filterInstanceDefinitionsByTargetAvailabilityStub.args[0][0].length, 1
        assert.equal filterInstanceDefinitionsByTargetAvailabilityStub.args[0][0][0].attributes.id, expectedInstanceDefinitionId

      it 'should return remaining instanceDefinitions after all previous filters', ->
        expectedInstanceDefinitionId = 'instance-1'
        result = do componentManager._filterInstanceDefinitions

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
              src: '../test/spec/MockComponent',
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
            src: '../test/spec/MockComponent',
            conditions: []
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header',
            showCount: 4
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'component-area--main',
            showCount: 1
          }
        ]

      it 'should return instanceDefinitions that passes componentConditions if 
      they are defined', ->
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

      it 'should not return instanceDefinitions that does not pass 
      componentConditions if they are defined', ->
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

      it 'should use global conditions if a string referenced is defined as
      condition in the condition model', ->
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

    describe '_filterInstanceDefinitionsByTargetAvailability', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'component-area--main'
          }
        ]

      beforeEach ->
        $('body').append '<div class="component-area--header"></div>'

        componentManager.initialize componentSettings
        do componentManager.refresh

      afterEach ->
        do $('.component-area--header').remove

      it 'should only return instanceDefinitions that has a target component-area
      which is currently present in the dom', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        result = componentManager._filterInstanceDefinitionsByTargetAvailability instanceDefinitions
        expectedResultId = 'instance-1'

        assert.equal result.length, 1
        assert.equal result[0].attributes.id, expectedResultId

    describe '_getInstanceArguments', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
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
            targetName: 'component-area--header'
            urlPattern: 'foo/:bar'
          }
          {
            id: 'instance-2',
            componentId: 'mock-iframe-component',
            targetName: 'component-area--header'
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
        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.get 'instance-1'
        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition
        assert.deepEqual result.urlParams, [urlParams]

      it 'should add urlParamsModel as an attribute on the args object', ->
        urlParams =
          bar: '123'
          url: 'foo/123'

        filter =
          url: 'foo/123'

        componentManager.refresh filter
        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.get 'instance-1'
        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition
        assert result.urlParamsModel instanceof Backbone.Model
        assert.deepEqual result.urlParamsModel.attributes, urlParams

      it 'should return arguments (args) defined on a component level', ->
        args =
          arg1: 1
          arg2: 2

        componentManager._componentDefinitionsCollection.models[0].attributes.args = args
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = undefined

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.get 'instance-1'

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition
        assert.equal result.arg1, args.arg1
        assert.equal result.arg2, args.arg2

      it 'should return arguments (args) defined on a instance level', ->
        args =
          arg1: 1
          arg2: 2

        componentManager._componentDefinitionsCollection.models[0].attributes.args = undefined
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = args

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition
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

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition

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

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition
        # urlParamsModel has a generated cid that might change and therefore is not suitable for testing
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

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-iframe-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[1]

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition

        assert.equal result.src, expectedResults.src

    describe '_addInstanceToModel', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
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

      it 'should call getComponentClassPromiseByInstanceDefinition on the componentDefinitionsCollection to get the the component Class which to create an instance from', ->
        getComponentClassByInstanceDefinitionSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentClassPromiseByInstanceDefinition'
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

      it 'it should create a new instance of the class defined in the componentDefinition and update the instanceDefinition with the instance', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        instanceDefinitionSetSpy = sandbox.spy instanceDefinition, 'set'

        componentManager._addInstanceToModel instanceDefinition

        instance = instanceDefinitionSetSpy.args[0][0].instance
        silentSetting = instanceDefinitionSetSpy.args[0][1]

        assert instanceDefinitionSetSpy.called
        assert instance instanceof MockComponent
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

      it 'it should return a componentClassPromise', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        result = componentManager._addInstanceToModel instanceDefinition
        assert _.isFunction(result.then)

    describe '_tryToReAddStraysToDom', ->
      settings =
        componentSettings:
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'component-area--header'
              urlPattern: 'foo/:bar'
            }
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'component-area--footer'
              urlPattern: 'foo/:bar'
            }
          ]

      beforeEach ->
        $('body').append '<div class="component-area--header"></div>'
        $('body').append '<div class="component-area--footer"></div>'
        componentManager.initialize settings

      afterEach ->
        do $('.component-area--header').remove
        do $('.component-area--footer').remove

      it 'should call _activeInstancesCollection.getStrays', ->
        getStraysSpy = sandbox.spy componentManager._activeInstancesCollection, 'getStrays'
        do componentManager._tryToReAddStraysToDom
        assert getStraysSpy.called

      it 'should call _addInstanceToDom and pass the stray and render = false for
      each stray returnd by getStrays', ->
        filter =
          url: 'foo/bar'

        render = false

        componentManager.refresh filter
        stray = componentManager._activeInstancesCollection.get 'instance-2'

        # making it a stray - it is active and should be present in the dom but
        # it has been removed
        do stray.get('instance').$el.remove

        addInstancesToDomStub = sandbox.stub componentManager, '_addInstanceToDom'
        do componentManager._tryToReAddStraysToDom

        firstCallArgs = addInstancesToDomStub.args[0]

        assert addInstancesToDomStub.calledOnce
        assert.equal firstCallArgs[0].id, 'instance-2'
        assert.equal firstCallArgs[1], render

      it 'if the instance was added to dom and there is a delegateEvents method
      it should be called', ->
        filter =
          url: 'foo/bar'

        componentManager.refresh filter

        stray = componentManager._activeInstancesCollection.get 'instance-2'

        # making it a stray - it is active and should be present in the dom but
        # it has been removed
        do stray.get('instance').$el.remove

        strays = componentManager._activeInstancesCollection.getStrays()

        firstStray = strays[0]
        componentManager._addInstanceToModel firstStray
        instance = firstStray.get 'instance'
        delegateEventsSpy = sandbox.spy instance, 'delegateEvents'
        do componentManager._tryToReAddStraysToDom
        assert delegateEventsSpy.called

      it 'if the instance was not added to the dom it means that there was no
      target for this instance and therefore it should be disposed', ->
        filter =
          url: 'foo/bar'

        componentManager.refresh filter

        stray = componentManager._activeInstancesCollection.get 'instance-2'

        # making it a stray - it is active and should be present in the dom but
        # it has been removed
        do stray.get('instance').$el.remove
        do $('.component-area--footer').remove

        strays = componentManager._activeInstancesCollection.getStrays()
        firstStray = strays[0]

        disposeInstanceSpy = sandbox.spy firstStray, 'disposeInstance'
        do componentManager._tryToReAddStraysToDom
        assert disposeInstanceSpy.called

    describe '_addInstanceToDom', ->
      settings =
        targetPrefix: 'test-prefix'
        componentSettings:
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
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
        componentManager.initialize settings

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
        settings = undefined
        beforeEach ->
          settings =
            targetPrefix: 'test-prefix'
            componentSettings:
              components: [
                {
                  id: 'mock-component',
                  src: '../test/spec/MockComponent'
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
          componentManager.initialize settings

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
          componentManager.initialize settings

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
          componentManager.initialize settings

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
          settings.componentSettings.instances[2].order = 'top'
          componentManager.initialize settings

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
          settings.componentSettings.instances[2].order = 'bottom'
          componentManager.initialize settings

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
          settings.componentSettings.instances[2].order = undefined
          componentManager.initialize settings

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

        settings =
          targetPrefix: 'test-prefix'
          componentSettings:
            components: [
              {
                id: 'mock-component',
                src: '../test/spec/MockComponent'
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

        componentManager.initialize settings

        filter =
          url: 'foo/1'

        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]
        isAttachedSpy = sandbox.spy instanceDefinition, 'isAttached'
        onAddedToDomSpy = sandbox.spy MockComponent.prototype, 'onAddedToDom'

        componentManager.refresh filter

        assert isAttachedSpy.called
        assert onAddedToDomSpy.called

      it 'should return the componentManager for chainability', ->
        settings =
          targetPrefix: 'test-prefix'
          componentSettings:
            components: [
              {
                id: 'mock-component',
                src: '../test/spec/MockComponent'
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

        componentManager.initialize settings
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        filter =
          url: 'foo/1'

        componentManager.refresh filter

        cm = componentManager._addInstanceInOrder instanceDefinition
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

    describe '_mapInstances', ->
      beforeEach ->
        settings =
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
            },
            {
              id: 'mock-component2',
              src: '../test/spec/MockComponent2'
            }
          ]

          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: 'body'
              urlPattern: 'foo/:bar'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component2',
              targetName: 'body'
              urlPattern: 'foo/:bar'
            },
            {
              id: 'instance-3',
              componentId: 'mock-component2',
              targetName: 'body'
              urlPattern: 'bar/:baz'
            }
          ]

        componentManager.initialize settings

      it 'should return the instances of the instanceDefinitions', ->
        createNewInstancesIfUndefined = false
        filter =
          url: 'foo/1'

        componentManager.refresh filter
        instanceDefinitions = componentManager._activeInstancesCollection.models
        instances = componentManager._mapInstances instanceDefinitions, createNewInstancesIfUndefined

        assert.equal instances.length, 2
        assert instances[0] instanceof MockComponent
        assert instances[1] instanceof MockComponent2

      it 'should create new instances if createNewInstancesIfUndefined is set to
      true and the instance is undefined', ->
        createNewInstancesIfUndefined = false
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        instances = componentManager._mapInstances instanceDefinitions, createNewInstancesIfUndefined
        assert.equal instances.length, 0

        createNewInstancesIfUndefined = true

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        instances = componentManager._mapInstances instanceDefinitions, createNewInstancesIfUndefined

        assert.equal instances.length, 3
        assert instances[0] instanceof MockComponent
        assert instances[1] instanceof MockComponent2
        assert instances[2] instanceof MockComponent2

      it 'should remove any undefined values from the array returned', ->
        compactSpy = sandbox.spy _, 'compact'
        createNewInstancesIfUndefined = false

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        instances = componentManager._mapInstances instanceDefinitions, createNewInstancesIfUndefined
        # in this case this array would have been containing two undefined values 
        # unless we called _.compact
        assert.equal instances.length, 0
        assert compactSpy.called

    describe '_isTargetAvailable', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header'
            urlPattern: 'foo/:bar'
            order: 1
            args:
              id: 'instance-1'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      afterEach ->
        do $('.component-area--header').remove

      it 'should return true if the passed instanceDefinitions target is
      available/present in the dom', ->
        $('body').append '<div class="component-area--header" id="test-header"></div>'
        instanceDefinition = componentManager._instanceDefinitionsCollection.at(0)
        isAvailable = componentManager._isTargetAvailable instanceDefinition
        assert.equal isAvailable, true

      it 'should return false if the passed instanceDefinitions target is not
      available/present in the dom', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.at(0)
        isAvailable = componentManager._isTargetAvailable instanceDefinition
        assert.equal isAvailable, false

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

    describe '_createAndAddInstances', ->
      isTargetAvailableSpy = undefined
      instanceDefinitions = undefined
      addInstanceToModelSpy = undefined
      addInstanceToDomStub = undefined

      beforeEach ->
        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
            }
          ]
          instanceDefinitions: [
            {
              id: 'dummy-instance',
              componentId: 'mock-component',
              targetName: '.component-area--header'
            }
            {
              id: 'dummy-instance2',
              componentId: 'mock-component',
              targetName: '.component-area--header'
            }
          ]

        componentManager.initialize componentSettings

        isTargetAvailableSpy = sandbox.spy componentManager, '_isTargetAvailable'
        addInstanceToModelSpy = sandbox.spy componentManager, '_addInstanceToModel'
        addInstanceToDomStub = sandbox.stub componentManager, '_addInstanceToDom'
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models

      afterEach ->
        do $('.component-area--header').remove

      it 'should call _isTargetAvailable and pass the instanceDefinition once for
      every instanceDefinition in the passed array', ->
        componentManager._createAndAddInstances instanceDefinitions
        assert isTargetAvailableSpy.calledTwice
        assert.equal isTargetAvailableSpy.args[0][0].get('id'), instanceDefinitions[0].get('id')
        assert.equal isTargetAvailableSpy.args[1][0].get('id'), instanceDefinitions[1].get('id')

      it 'should call _addInstanceToModel once for each instanceDefinition - if target is available', ->
        $('body').append '<div class="component-area--header"></div>'
        componentManager._createAndAddInstances instanceDefinitions
        assert addInstanceToModelSpy.calledTwice
        assert isTargetAvailableSpy.calledTwice
        assert.equal addInstanceToModelSpy.args[0][0].get('id'), instanceDefinitions[0].get('id')
        assert.equal addInstanceToModelSpy.args[1][0].get('id'), instanceDefinitions[1].get('id')

      it 'should not call _addInstanceToModel once for each instanceDefinition - if target is not available', ->
        componentManager._createAndAddInstances instanceDefinitions
        assert isTargetAvailableSpy.calledTwice
        assert addInstanceToModelSpy.notCalled

      it 'should call _addInstanceToDom once for each instanceDefinition - if target is available', ->
        $('body').append '<div class="component-area--header"></div>'
        componentManager._createAndAddInstances instanceDefinitions
        assert addInstanceToDomStub.calledTwice
        assert isTargetAvailableSpy.calledTwice
        assert.equal addInstanceToDomStub.args[0][0].get('id'), instanceDefinitions[0].get('id')
        assert.equal addInstanceToDomStub.args[1][0].get('id'), instanceDefinitions[1].get('id')

      it 'should not call _addInstanceToDom once for each instanceDefinition - if target is not available', ->
        componentManager._createAndAddInstances instanceDefinitions
        assert isTargetAvailableSpy.calledTwice
        assert addInstanceToDomStub.notCalled

      it 'should call incrementShowCount once for each instanceDefinition - if target is available', ->
        $('body').append '<div class="component-area--header"></div>'
        spies = []
        for instanceDefinition in instanceDefinitions
          spies.push sandbox.spy(instanceDefinition, 'incrementShowCount')

        componentManager._createAndAddInstances instanceDefinitions

        assert isTargetAvailableSpy.calledTwice
        for spy in spies
          assert spy.called

      it 'should not call incrementShowCount once for each instanceDefinition - if target is not available', ->
        spies = []
        for instanceDefinition in instanceDefinitions
          spies.push sandbox.spy(instanceDefinition, 'incrementShowCount')

        componentManager._createAndAddInstances instanceDefinitions

        assert isTargetAvailableSpy.calledTwice

        for spy in spies
          assert spy.notCalled

      it 'should return the array of instanceDefinitions', ->
        returned = componentManager._createAndAddInstances instanceDefinitions
        assert.equal returned, instanceDefinitions

    describe '_getTarget', ->
      instanceDefinitions = undefined

      beforeEach ->
        $('body').append '<div class="component-area--test-target" id="test-header"></div>'
        componentSettings =
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
            }
          ]
          instanceDefinitions: [
            {
              id: 'dummy-instance',
              componentId: 'dummy-component',
              targetName: 'body'
            }
            {
              id: 'dummy-instance2',
              componentId: 'dummy-component2',
              targetName: 'component-area--test-target'
            }
          ]

        instanceDefinitions = componentSettings.instanceDefinitions
        componentManager.initialize componentSettings

      afterEach ->
        $('component-area--test-target').remove()

      it 'should return the passed instanceDefinitions targetName as a jQuery object', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.at(1)
        $target = componentManager._getTarget instanceDefinition
        assert $target instanceof $
        assert.equal $target.attr('class'), instanceDefinitions[1].targetName

      it 'should return the passed instanceDefinitions targetName as a jQuery object even if the targetName is body', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.at(0)
        $target = componentManager._getTarget instanceDefinition
        assert $target instanceof $
        assert.equal $target.selector, instanceDefinitions[0].targetName

    describe '_modelToJSON', ->
      model = new Backbone.Model id: '123'

      it 'should call toJSON() on the model', ->
        toJSONSpy = sandbox.spy model, 'toJSON'
        componentManager._modelToJSON model
        assert toJSONSpy.called

      it 'should return the result of model.toJSON()', ->
        expectedResult =
          id: '123'

        modelJSON = componentManager._modelToJSON model
        assert.deepEqual modelJSON, expectedResult

    describe '_modelsToJSON', ->
      collection = new Backbone.Collection [
        {id: '123'}
        {id: '124'}
      ]
      models = collection.models

      it 'should map passed models through modelToJSON', ->
        modelsToJSONSpy = sandbox.spy componentManager, '_modelToJSON'
        mapSpy = sandbox.spy _, 'map'

        componentManager._modelsToJSON models
        assert modelsToJSONSpy.calledTwice

        firstCall = modelsToJSONSpy.getCall 0
        secondCall = modelsToJSONSpy.getCall 1

        assert firstCall.calledWith models[0]
        assert secondCall.calledWith models[1]
        assert mapSpy.calledWith models, componentManager._modelToJSON

      it 'should return an array of JSON representations of the passed models', ->
        expectedResult = [
          {id: '123'},
          {id: '124'}
        ]

        result = componentManager._modelsToJSON models
        assert.deepEqual result, expectedResult

  # Callbacks
  ##############################################################################
  describe 'callbacks', ->
    componentSettings = undefined
    instanceDefinition = undefined
    beforeEach ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: 'component-area--header'
            urlPattern: 'foo/:bar'
            order: 1
            args:
              id: 'instance-1'
          }
        ]

      componentManager.initialize componentSettings
      instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

    describe '_onActiveInstanceAdd', ->
      it 'should call _createAndAddInstances and pass the added instanceDefinition', ->
        createAndAddInstancesStub = sandbox.stub componentManager, '_createAndAddInstances'
        componentManager._onActiveInstanceAdd instanceDefinition

        assert createAndAddInstancesStub.calledWith instanceDefinition

    describe '_onActiveInstanceChange', ->
      it 'should call toJSON on the _filterModel', ->
        toJSONSpy = sandbox.spy componentManager._filterModel, 'toJSON'
        componentManager._onActiveInstanceChange instanceDefinition

        assert toJSONSpy.called

      it 'should call toJSON on the _globalConditionsModel', ->
        toJSONSpy = sandbox.spy componentManager._globalConditionsModel, 'toJSON'
        componentManager._onActiveInstanceChange instanceDefinition

        assert toJSONSpy.called

      it 'should call passesFilter on the instanceDefinition and pass active filters and global conditions', ->
        passesFilterSpy = sandbox.spy instanceDefinition, 'passesFilter'
        filter = componentManager._filterModel.toJSON()
        globalConditions = componentManager._globalConditionsModel.toJSON()
        componentManager._onActiveInstanceChange instanceDefinition

        assert passesFilterSpy.calledWith filter, globalConditions

      it 'should call _isTargetAvailable and pass the instanceDefinition', ->
        isTargetAvailableSpy = sandbox.spy componentManager, '_isTargetAvailable'
        componentManager._onActiveInstanceChange instanceDefinition
        assert isTargetAvailableSpy.calledWith instanceDefinition

      describe 'if the changed instanceDefinition passes the filter check and the target is available', ->
        beforeEach ->
          $('body').append '<div class="component-area--header" id="test-header"></div>'

        afterEach ->
          do $('.component-area--header').remove

        it 'it should call disposeInstance on the instanceDefinition', ->
          disposeInstanceSpy = sandbox.spy instanceDefinition, 'disposeInstance'
          componentManager._onActiveInstanceChange instanceDefinition
          assert disposeInstanceSpy.called

        it 'it should call _addInstanceToModel and pass the instanceDefinition', ->
          addInstanceToModelSpy = sandbox.spy componentManager, '_addInstanceToModel'
          componentManager._onActiveInstanceChange instanceDefinition
          assert addInstanceToModelSpy.calledWith instanceDefinition

        it 'it should call _addInstanceToDom and pass the instanceDefinition', ->
          addInstanceToDomSpy = sandbox.spy componentManager, '_addInstanceToDom'
          componentManager._onActiveInstanceChange instanceDefinition
          assert addInstanceToDomSpy.calledWith instanceDefinition

      describe 'if the changed instanceDefinition passes the filter check and the target is not available', ->
        it 'it should not call disposeInstance on the instanceDefinition', ->
          disposeInstanceSpy = sandbox.spy instanceDefinition, 'disposeInstance'
          componentManager._onActiveInstanceChange instanceDefinition
          assert disposeInstanceSpy.notCalled

        it 'it should not call _addInstanceToModel and pass the instanceDefinition', ->
          addInstanceToModelSpy = sandbox.spy componentManager, '_addInstanceToModel'
          componentManager._onActiveInstanceChange instanceDefinition
          assert addInstanceToModelSpy.notCalled

        it 'it should call _addInstanceToDom and pass the instanceDefinition', ->
          addInstanceToDomSpy = sandbox.spy componentManager, '_addInstanceToDom'
          componentManager._onActiveInstanceChange instanceDefinition
          assert addInstanceToDomSpy.notCalled

    describe '_onActiveInstanceRemoved', ->
      it 'should call disposeInstance on the instanceDefinition', ->
        disposeInstanceSpy = sandbox.spy instanceDefinition, 'disposeInstance'
        componentManager._onActiveInstanceRemoved instanceDefinition
        assert disposeInstanceSpy.called

      it 'should call _setComponentAreaPopulatedState and pass the removed instance target', ->
        setComponentAreaPopulatedStateSpy = sandbox.spy componentManager, '_setComponentAreaPopulatedState'
        componentManager._onActiveInstanceRemoved instanceDefinition
        assert setComponentAreaPopulatedStateSpy.called

    describe '_onActiveInstanceOrderChange', ->
      it 'should call _addInstanceToDom and pass the changed instanceDefinition', ->
        addInstanceToDomStub = sandbox.stub componentManager, '_addInstanceToDom'
        componentManager._onActiveInstanceOrderChange instanceDefinition
        assert addInstanceToDomStub.called

    describe '_onActiveInstanceTargetNameChange', ->
      it 'should call _addInstanceToDom and pass the changed instanceDefinition', ->
        addInstanceToDomStub = sandbox.stub componentManager, '_addInstanceToDom'
        componentManager._onActiveInstanceOrderChange instanceDefinition
        assert addInstanceToDomStub.called
