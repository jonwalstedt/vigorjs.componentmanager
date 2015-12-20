assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../dist/vigor.componentmanager'

componentManager = new Vigor.ComponentManager()
__testOnly = Vigor.ComponentManager.__testOnly

ComponentDefinitionsCollection = __testOnly.ComponentDefinitionsCollection
InstanceDefinitionsCollection = __testOnly.InstanceDefinitionsCollection
ActiveInstancesCollection = __testOnly.ActiveInstancesCollection
FilterModel = __testOnly.FilterModel

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

        filterModelSet = sandbox.spy componentManager._filterModel, 'set'
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
                targetName: '.test-prefix--header'
                urlPattern: 'foo/:bar'
                order: 1
                args:
                  id: 'instance-1'
              }
            ]

        componentManager.initialize settings

      afterEach ->
        do $('.test-prefix--header').remove

      it 'should call toJSON on the globalConditionsModel', ->
        toJSONSpy = sandbox.spy componentManager._globalConditionsModel, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call toJSON on the _componentDefinitionsCollection', ->
        toJSONSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call toJSON on the _instanceDefinitionsCollection', ->
        toJSONSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'toJSON'
        do componentManager.serialize
        assert toJSONSpy.called

      it 'should call getComponentClassName', ->
        getComponentClassNameSpy = sandbox.spy componentManager, 'getComponentClassName'
        do componentManager.serialize
        assert getComponentClassNameSpy.called

      it 'should call getTargetPrefix', ->
        getTargetPrefixSpy = sandbox.spy componentManager, 'getTargetPrefix'
        do componentManager.serialize
        assert getTargetPrefixSpy.called

      it 'should stringify current state of the componentManager so that it can
      be parsed back at a later time', ->
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
              targetName: '.test-prefix--header'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: '.test-prefix--main'
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
              targetName: '.test-prefix--header'
              reInstantiate: false
              showCount: 0
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: '.test-prefix--main'
              reInstantiate: false
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
                targetName: '.test-prefix--header'
              },
              {
                id: 'instance-2',
                urlPattern: 'bar/:id'
                componentId: 'mock-component',
                targetName: '.test-prefix--main'
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
          includeIfMatch: undefined
          excludeIfMatch: undefined
          hasToMatch: undefined
          cantMatch: undefined
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
        componentManager._componentDefinitionsCollection = new ComponentDefinitionsCollection()
        componentManager._instanceDefinitionsCollection = new InstanceDefinitionsCollection()
        componentManager._activeInstancesCollection = new ActiveInstancesCollection()
        componentManager._globalConditionsModel = new Backbone.Model()
        componentManager._filterModel = new FilterModel()

      it 'should add a throttled_diff listener on the _componentDefinitionsCollection
      with _updateActiveComponents as callback', ->
        componentDefinitionsCollectionOnSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'on'
        updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'

        do componentManager.addListeners
        assert componentDefinitionsCollectionOnSpy.calledWith 'throttled_diff', componentManager._updateActiveComponents

        componentManager._componentDefinitionsCollection.trigger 'change', new Backbone.Model()
        assert.equal updateActiveComponentsSpy.called, false
        clock.tick 51
        assert updateActiveComponentsSpy.called

      it 'should add a throttled_diff listener on the _instanceDefinitionsCollection
      with _updateActiveComponents as callback', ->
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
        do componentManager.addListeners
        componentManager.on componentManager.EVENTS.CHANGE, changeSpy
        componentManager._activeInstancesCollection.trigger 'change', new Backbone.Model()
        assert changeSpy.called

      it 'should proxy remove events from the _activeInstancesCollection (EVENTS.REMOVE)', ->
        removeSpy = sandbox.spy()
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
        assert.equal componentManager._instanceDefinitionsCollection.get('dummy-instance').toJSON().targetName, '.component-area--header'

      it 'should return the componentManager for chainability', ->
        instance =
          id: 'dummy-instance',
          componentId: 'dummy-component',
          targetName: 'body'

        cm = componentManager.initialize().updateInstanceDefinitions instance
        assert.equal cm, componentManager



    describe 'removeComponentDefinition', ->
      it 'should remove all instanceDefinitions referencing the componentDefinition
      thats about to be removed', ->
        componentSettings =
          components: [
            {
              id: 'dummy-component',
              src: MockComponent
            }
            {
              id: 'dummy-component2',
              src: MockComponent
            }
          ]
          instances: [
            {
              id: 'instance1'
              componentId: 'dummy-component'
              targetName: 'body'
            }
            {
              id: 'instance2'
              componentId: 'dummy-component'
              targetName: 'body'
            }
            {
              id: 'instance3'
              componentId: 'dummy-component2'
              targetName: 'body'
            }
            {
              id: 'instance4'
              componentId: 'dummy-component2'
              targetName: 'body'
            }
          ]
        componentManager.initialize componentSettings

        removeSpy = sandbox.spy componentManager._instanceDefinitionsCollection, 'remove'
        expectedInstanceDefinitionsToBeRemoved = [componentManager._instanceDefinitionsCollection.at(2), componentManager._instanceDefinitionsCollection.at(3)]

        assert componentManager._instanceDefinitionsCollection.models.length, 4

        componentManager.removeComponentDefinition 'dummy-component2'

        assert removeSpy.calledWith expectedInstanceDefinitionsToBeRemoved
        assert.equal componentManager._instanceDefinitionsCollection.models.length, 2
        assert.equal componentManager._instanceDefinitionsCollection.at(0).toJSON().id, 'instance1'
        assert.equal componentManager._instanceDefinitionsCollection.at(1).toJSON().id, 'instance2'


      it 'should call remove on the _componentDefinitionsCollection with passed
      componentDefinitionId', ->
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
            targetName: 'body'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: 'body'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

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

      describe 'if updateActiveComponents is set to true', ->
        it 'should call unsetTarget on all registerd instanceDefinitions', ->
          instanceDefinitions = componentManager._instanceDefinitionsCollection.models
          assert.equal instanceDefinitions.length, 2

          spies = []
          for instanceDefinition in instanceDefinitions
            spies.push sandbox.spy instanceDefinition, 'unsetTarget'

          componentManager.setContext '.header'

          for spy in spies
            assert spy.called

        it 'should remove all active instances by calling reset on
        _activeInstancesCollection', ->
          resetSpy = sandbox.spy componentManager._activeInstancesCollection, 'reset'
          componentManager.setContext '.header'
          assert resetSpy.called

        it 'should try to recreate and add instances by calling
        _updateActiveComponents', ->
          updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'
          componentManager.setContext '.header'
          assert updateActiveComponentsSpy.called

      describe 'if updateActiveComponents is set to false', ->
        it 'should NOT call unsetTarget on all registerd instanceDefinitions', ->
          instanceDefinitions = componentManager._instanceDefinitionsCollection.models
          assert.equal instanceDefinitions.length, 2
          updateActiveComponents = false

          spies = []
          for instanceDefinition in instanceDefinitions
            spies.push sandbox.spy instanceDefinition, 'unsetTarget'

          componentManager.setContext '.header', updateActiveComponents

          for spy in spies
            assert spy.notCalled

        it 'should NOT remove all active instances by calling reset on
        _activeInstancesCollection', ->
          resetSpy = sandbox.spy componentManager._activeInstancesCollection, 'reset'
          updateActiveComponents = false
          componentManager.setContext '.header', updateActiveComponents
          assert resetSpy.notCalled

        it 'should NOT try to recreate and add instances by calling
        _updateActiveComponents', ->
          updateActiveComponentsSpy = sandbox.spy componentManager, '_updateActiveComponents'
          updateActiveComponents = false
          componentManager.setContext '.header', updateActiveComponents
          assert updateActiveComponentsSpy.notCalled




    describe 'setComponentClassName', ->
      it 'should save the componentClassName', ->
        componentClassName = 'dummy-class-name'
        componentManager.setComponentClassName componentClassName
        assert.equal componentManager._componentClassName, componentClassName

      it 'should use default componentClassName if method is called without
      passing a new name', ->
        componentClassName = 'dummy-class-name'
        componentManager.setComponentClassName componentClassName
        assert.equal componentManager._componentClassName, componentClassName

        do componentManager.setComponentClassName
        assert.equal componentManager._componentClassName, 'vigor-component'

      it 'should set the new componentClassName on all
      activeInstanceDefinitionModels "componentClassName" property', ->
        settings =
          componentClassName: 'my-component-class-name'
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
                targetName: 'body'
              },
              {
                id: 'instance-2',
                componentId: 'mock-component',
                targetName: 'body'
              }
            ]

        spies = []
        newComponentClassName = 'my-new-component-class-name'

        componentManager.initialize settings
        componentManager.refresh()

        activeInstanceDefinitions = componentManager._activeInstancesCollection.models

        assert.equal activeInstanceDefinitions.length, 2

        for activeInstanceDefinition in activeInstanceDefinitions
          spies.push sandbox.spy activeInstanceDefinition, 'set'

        componentManager.setComponentClassName newComponentClassName

        for spy in spies
          assert spy.calledWith componentClassName: newComponentClassName

      it 'should return the componentManager for chainability', ->
        cm = componentManager.setComponentClassName()
        assert.equal cm, componentManager



    describe 'setTargetPrefix', ->
      it 'should store the target prefix', ->
        targetPrefix = 'dummy-prefix'
        componentManager.setTargetPrefix targetPrefix
        assert.equal componentManager._targetPrefix, targetPrefix

      it 'should use default target prefix if method is called without passing a
      new prefix', ->
        targetPrefix = 'dummy-prefix'
        componentManager.setTargetPrefix targetPrefix
        assert.equal componentManager._targetPrefix, targetPrefix

        do componentManager.setTargetPrefix
        assert.equal componentManager._targetPrefix, 'component-area'

      it 'should call updateTargetPrefix on each _instanceDefinitionsCollection
      with the new targetPrefix', ->
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
              targetName: 'body'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'body'
            }
          ]

        spies = []
        newTargetPrefix = 'new-prefix'

        componentManager.initialize componentSettings

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models

        assert.equal instanceDefinitions.length, 2

        for instanceDefinition in instanceDefinitions
          spies.push sandbox.spy instanceDefinition, 'updateTargetPrefix'

        componentManager.setTargetPrefix newTargetPrefix

        for spy in spies
          assert spy.calledWith newTargetPrefix


      it 'should return the componentManager for chainability', ->
        cm = componentManager.setTargetPrefix()
        assert.equal cm, componentManager



    describe 'getContext', ->
      it 'should return the context', ->
        $context = $('<div/>')
        do componentManager.initialize
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
          includeIfMatch: 'baz'

        expectedResults =
          url: 'foo/bar'
          filterString: undefined
          includeIfMatch: 'baz'
          excludeIfMatch: undefined
          hasToMatch: undefined
          cantMatch: undefined
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
      it 'should call _mapInstances with _activeInstancesCollection.models', ->

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
        assert mapInstancesSpy.calledWith componentManager._activeInstancesCollection.models



    describe 'getActiveInstanceById', ->
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
            targetName: '.component-area--header'
            urlPattern: 'foo/:bar'
            order: 1
            args:
              id: 'instance-1'
          }
        ]

      beforeEach ->
        $('body').append '<div class="component-area--header"></div>'

        afterEach ->
          do $('.component-area--header').remove

        componentManager.initialize componentSettings

      it 'should call _activeInstancesCollection.getInstanceDefinition with the passed id', ->
        getInstanceDefinitionStub = sandbox.stub componentManager._activeInstancesCollection, 'getInstanceDefinition'
        id = 'instance-1'
        componentManager.getActiveInstanceById id
        assert getInstanceDefinitionStub.calledWith(id)

      it 'should return the instance from the instanceDefinitionModel if it exists', ->
        id = 'instance-1'
        filter =
          url: 'foo/1'

        componentManager.refresh filter

        instance = componentManager.getActiveInstanceById id
        assert instance instanceof MockComponent

      it 'should return undefined if there is no instance in the targeted instanceDefinition', ->
        id = 'instance-1'
        filter =
          url: 'foo/1'

        componentManager.refresh filter

        do componentManager._activeInstancesCollection.get(id)._disposeInstance
        instance = componentManager.getActiveInstanceById id
        assert.equal instance, undefined



    describe 'postMessageToInstance', ->
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
            targetName: '.component-area--header'
            urlPattern: 'foo/:bar'
            order: 1
            args:
              id: 'instance-1'
          }
        ]

      beforeEach ->
        $('body').append '<div class="component-area--header" id="test-header"></div>'

        afterEach ->
          do $('.component-area--header').remove

        filter =
          url: 'foo/1'

        componentManager.initialize componentSettings
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

      it 'should call setContext and pass the context from the passed settings
      (if it is defined)', ->
        $test = $('.test')

        settings =
          context: $test

        setContextSpy = sandbox.spy componentManager, 'setContext'

        componentManager._parse settings
        assert setContextSpy.calledWith $test

      it 'should call setComponentClassName with the componentClassName from the
      passed settings (if it is defined)', ->

        componentClassName = 'dummy-component-class-name'

        settings =
          componentClassName: componentClassName

        setComponentClassNameSpy = sandbox.spy componentManager, 'setComponentClassName'

        componentManager._parse settings
        assert setComponentClassNameSpy.calledWith componentClassName

      it 'should call setTargetPrefix with the targetPrefix from the passed
      settings (if it is defined)', ->
        targetPrefix = 'dummy-target-prefix'

        settings =
          targetPrefix: targetPrefix

        setTargetPrefixSpy = sandbox.spy componentManager, 'setTargetPrefix'

        componentManager._parse settings
        assert setTargetPrefixSpy.calledWith targetPrefix

      it 'should call _parseComponentSettings with the componentSettings from the
      passed settings (if it is defined)', ->
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

      it 'should call _parseComponentSettings with settings if componentSettings
      is not defined in the settings object', ->
        settings =
          someOtherSettings: 'something not related to _parseComponentSettings'

        componentManager._parse settings
        assert parseComponentSettingsStub.calledWith settings

      it 'should return the componentManager for chainability', ->
        cm = componentManager._parse()
        assert.equal cm, componentManager



    describe '_parseComponentSettings', ->
      it 'should call addConditions with passed conditions and silent set to true,
      if conditions are defined (and is an object that is not empty) in the passed
      componentSettings object', ->
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

      it 'should not call _registerComponentDefinitions if niether components,
      widgets or componentDefinitions are defined in componentSettings', ->
        registerComponentsStub = sandbox.stub componentManager, '_registerComponentDefinitions'
        componentSettings =
          someOtherSettings: 'something not related to _registerComponentDefinitions'

        componentManager._parseComponentSettings componentSettings
        assert.equal registerComponentsStub.called, false


      it 'should not call _registerInstanceDefinitions if niether layoutsArray,
      targets, instanceDefinitions, instances are defined in componentSettings', ->
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
        componentManager._componentDefinitionsCollection = new ComponentDefinitionsCollection()
        componentDefinitionsCollectionSetStub = sandbox.stub componentManager._componentDefinitionsCollection, 'set'

      it 'should call _componentDefinitionsCollection.set with passed componentDefinitions,
      validate: true, parse: true and silent: true', ->
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
        componentManager._instanceDefinitionsCollection = new InstanceDefinitionsCollection()
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
            targetName: '.component-area--header'
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
        componentManager.initialize componentSettings
        $('body').append '<div class="component-area--header"></div>'
        $('body').append '<div class="component-area--main"></div>'

      afterEach ->
        do $('.component-area--header').remove
        do $('.component-area--main').remove

      it 'should get the current filterOptions', ->
        getSpy = sandbox.spy componentManager._filterModel, 'get'
        do componentManager._updateActiveComponents
        assert getSpy.calledWith 'options'

      it 'should call _filterInstanceDefinitions', ->
        filterInstanceDefinitionsSpy = sandbox.spy componentManager, '_filterInstanceDefinitions'

        do componentManager._updateActiveComponents
        assert filterInstanceDefinitionsSpy.called

      it 'should call getComponentClassPromisesByInstanceDefinitions to get class promises
      for all active instanceDefinitions', ->
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
      promise with an object containg active filter, active instances, active
      instanceDefinitions, last changed instancecs, and last changed
      instanceDefinitions', ->
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

      it 'should call _createActiveInstanceDefinitionObjects with the filtered
      instanceDefinitions', ->
        createActiveInstanceDefinitionObjectsSpy = sandbox.spy componentManager, '_createActiveInstanceDefinitionObjects'

        filter =
          url: 'foo/1'

        componentManager._filterModel.set filter
        filteredInstanceDefinitions = do componentManager._filterInstanceDefinitions

        do componentManager._updateActiveComponents

        assert createActiveInstanceDefinitionObjectsSpy.calledWith filteredInstanceDefinitions

      it 'should call set on the _activeInstancesCollection with the objects from
      _createActiveInstanceDefinitionObjects and the filter options', ->
        setStub = sandbox.stub componentManager._activeInstancesCollection, 'set'

        filter =
          url: 'foo/1'

        componentManager._filterModel.set filter
        options = componentManager._filterModel.get 'options'

        filteredInstanceDefinitions = do componentManager._filterInstanceDefinitions

        do componentManager._updateActiveComponents

        componentClassPromise = componentManager._componentDefinitionsCollection.get 'mock-component'
        $.when(componentClassPromise).then =>
          activeInstanceDefinitionObjs = componentManager._createActiveInstanceDefinitionObjects filteredInstanceDefinitions
          assert setStub.calledWith activeInstanceDefinitionObjs, options

      it 'should invoke tryToReAddStraysToDom on the lastChanged activeInstanceDefinitions', ->
        invokeSpy = sandbox.spy _, 'invoke'

        filter =
          url: 'foo/1'

        componentManager._filterModel.set filter
        do componentManager._updateActiveComponents
        activeComponentDefinition = componentManager._activeInstancesCollection.get('instance-1')

        assert invokeSpy.calledWith [activeComponentDefinition], 'tryToReAddStraysToDom'

      it 'should resolve its promise with instances NOT matching the filter if
      options.invert is set to true', ->
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

      it 'should resolve promise with all active instances and the last
      changed/added instances - and they might not allways be the same depending
      on the provided options', ->
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

      it 'should return a promise', ->
        do componentManager.initialize
        result = do componentManager._updateActiveComponents
        assert _.isFunction(result.then)



    describe '_createActiveInstanceDefinitionObjects', ->
      instanceDefinitions = undefined
      componentDefinitions = undefined
      settings =
        componentClassName: 'my-class-name'
        targetPrefix: 'my-target-prefix'
        componentSettings:
          components: [
            {
              id: 'mock-component',
              src: '../test/spec/MockComponent'
              args:
                componentLvlArg: 'first'
            }
            {
              id: 'mock-component-2',
              src: '../test/spec/MockComponent2'
            }
          ]
          instances: [
            {
              id: 'instance-1',
              componentId: 'mock-component',
              targetName: '.my-target-prefix--header'
              urlPattern: 'foo/:id'
              order: 1
              reInstantiate: true
              args:
                instanceLvlArg: 'second'
            },
            {
              id: 'instance-2',
              componentId: 'mock-component-2',
              targetName: '.my-target-prefix--header'
              urlPattern: 'bar/:id'
              order: 2
              args:
                instanceLvlArg: 'first'
            }
          ]

      beforeEach ->
        $('body').append '<div class="my-target-prefix--header"></div>'
        componentManager.initialize settings
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        componentDefinitions = componentManager._componentDefinitionsCollection.models
        # setting the componentClass so we can run the method synchronously
        componentManager._componentDefinitionsCollection.get('mock-component').set 'componentClass', MockComponent
        componentManager._componentDefinitionsCollection.get('mock-component-2').set 'componentClass', MockComponent2

      afterEach ->
        $('.my-target-prefix--header').remove
        instanceDefinitions = undefined
        componentDefinitions = undefined

      it 'should add the correct id to each activeInstanceDefinition
      object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].id, 'instance-1'
        assert.equal results[1].id, 'instance-2'

      it 'should add the correct componentClass to each activeInstanceDefinition
      object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].componentClass, MockComponent
        assert.equal results[1].componentClass, MockComponent2


      it 'should add the correct target to each activeInstanceDefinition
      object', ->
        $expectedTarget = $ '.my-target-prefix--header'
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.deepEqual results[0].target[0], $expectedTarget[0]
        assert.equal results[1].target[0], $expectedTarget[0]

      it 'should add the correct targetPrefix to each activeInstanceDefinition
      object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].targetPrefix, 'my-target-prefix'
        assert.equal results[1].targetPrefix, 'my-target-prefix'

      it 'should add the correct componentClassName to each
      activeInstanceDefinition object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].componentClassName, 'my-class-name'
        assert.equal results[1].componentClassName, 'my-class-name'

      it 'should add the correct instanceArguments to each
      activeInstanceDefinition object', ->
        firstExpectedInstanceArguments =
          componentLvlArg: 'first'
          instanceLvlArg: 'second'

        secondExpectedInstanceArguments =
          instanceLvlArg: 'first'

        getInstanceArgumentsSpy = sandbox.spy componentManager, '_getInstanceArguments'
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions

        assert getInstanceArgumentsSpy.calledTwice
        assert getInstanceArgumentsSpy.firstCall.calledWith instanceDefinitions[0], componentDefinitions[0]
        assert getInstanceArgumentsSpy.secondCall.calledWith instanceDefinitions[1], componentDefinitions[1]

        assert.deepEqual results[0].instanceArguments, firstExpectedInstanceArguments
        assert.deepEqual results[1].instanceArguments, secondExpectedInstanceArguments

      it 'should add the correct order to each activeInstanceDefinition object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].order, 1
        assert.equal results[1].order, 2

      it 'should add the correct reInstantiate value to each
      activeInstanceDefinition object', ->
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.equal results[0].reInstantiate, true
        assert.equal results[1].reInstantiate, false

      it 'should add the correct urlParams to each activeInstanceDefinition
      object', ->
        firstExpectedUrlParams = [
          {
            _id: 'foo/:id'
            id: '1'
            url: 'foo/1'
          }
        ]

        secondExpectedUrlParams = [
          {
            _id: 'bar/:id'
            url: 'foo/1'
          }
        ]

        componentManager._filterModel.set componentManager._filterModel.parse(url: 'foo/1')

        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.deepEqual results[0].urlParams, firstExpectedUrlParams
        assert.deepEqual results[1].urlParams, secondExpectedUrlParams

        firstExpectedUrlParams = [
          {
            _id: 'foo/:id'
            url: 'bar/1'
          }
        ]

        secondExpectedUrlParams = [
          {
            _id: 'bar/:id'
            id: '1'
            url: 'bar/1'
          }
        ]

        componentManager._filterModel.set componentManager._filterModel.parse(url: 'bar/1')

        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions
        assert.deepEqual results[0].urlParams, firstExpectedUrlParams
        assert.deepEqual results[1].urlParams, secondExpectedUrlParams

      it 'should add the correct serializedFilter to each activeInstanceDefinition
      object', ->
        componentManager._filterModel.set componentManager._filterModel.parse(url: 'bar/1')
        serializedFilterSpy = sandbox.spy componentManager._filterModel, 'serialize'
        excludeOptions = true

        expectedResult = '{"url":"bar/1"}'
        results = componentManager._createActiveInstanceDefinitionObjects instanceDefinitions

        assert serializedFilterSpy.calledOnce
        assert serializedFilterSpy.calledWith excludeOptions
        assert.equal results[0].serializedFilter, expectedResult
        assert.equal results[1].serializedFilter, expectedResult



    describe '_filterInstanceDefinitions', ->
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
            targetName: '.component-area--header',
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
        $('body').append '<div class="component-area--header"></div>'
        $('body').append '<div class="component-area--main"></div>'
        componentManager.initialize componentSettings
        componentManager.refresh
          url: 'foo/bar'

      afterEach ->
        do $('.component-area--header').remove
        do $('.component-area--main').remove

      it 'should call _filterInstanceDefinitionsByComponentLevelFilters with
      _instanceDefinitionsCollection.models', ->
        filterInstanceDefinitionsByComponentLevelFiltersStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByComponentLevelFilters'
        do componentManager._filterInstanceDefinitions
        assert filterInstanceDefinitionsByComponentLevelFiltersStub.calledWith componentManager._instanceDefinitionsCollection.models

      it 'should call _filterInstanceDefinitionsByInstanceLevelFilters with the
      instanceDefinitions returned from
      _filterInstanceDefinitionsByComponentLevelFilters', ->
        filterInstanceDefinitionsByInstanceLevelFiltersStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByComponentLevelFilters'
        do componentManager._filterInstanceDefinitions
        assert filterInstanceDefinitionsByInstanceLevelFiltersStub.calledWith componentManager._instanceDefinitionsCollection.models

      it 'should call _filterInstanceDefinitionsByCustomProperties with the
      instanceDefinitions that was returned by
      _filterInstanceDefinitionsByInstanceLevelFilters', ->
        expectedArgument = [
          componentManager._instanceDefinitionsCollection.get('instance-1')
        ]
        filterInstanceDefinitionsByCustomPropertiesStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByCustomProperties'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByCustomPropertiesStub.calledWith expectedArgument

      it 'should call _filterInstanceDefinitionsByShowCount with the
      instanceDefinitions that was returned by
      _filterInstanceDefinitionsByCustomProperties', ->
        expectedArgument = [
          componentManager._instanceDefinitionsCollection.get('instance-1')
        ]
        filterInstanceDefinitionsByShowCountStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByShowCount'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByShowCountStub.calledWith expectedArgument

      it 'should call _filterInstanceDefinitionsByTargetAvailability with the
      instanceDefinitions that was returned by
      _filterInstanceDefinitionsByShowCount', ->
        expectedArgument = [
          componentManager._instanceDefinitionsCollection.get('instance-1')
        ]
        filterInstanceDefinitionsByTargetAvailabilityStub = sandbox.stub componentManager, '_filterInstanceDefinitionsByTargetAvailability'
        do componentManager._filterInstanceDefinitions

        assert filterInstanceDefinitionsByTargetAvailabilityStub.calledWith expectedArgument

      it 'should return remaining instanceDefinitions after all previous filters', ->
        expectedInstanceDefinitionId = 'instance-1'
        result = do componentManager._filterInstanceDefinitions
        assert.equal result.length, 1
        assert.equal result[0].attributes.id, expectedInstanceDefinitionId



    describe '_filterInstanceDefinitionsByComponentLevelFilters', ->
      componentSettings =
        components: [
          {
            id: 'mock-component-1',
            src: '../test/spec/MockComponent',
            conditions: ->
              return false
          },
          {
            id: 'mock-component-2',
            src: '../test/spec/MockComponent',
            conditions: ->
              return true
          },
          {
            id: 'mock-component-3',
            src: '../test/spec/MockComponent'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component-1',
            targetName: '.component-area--header',
          },
          {
            id: 'instance-2',
            componentId: 'mock-component-2',
            targetName: '.component-area--header'
          },
          {
            id: 'instance-3',
            componentId: 'mock-component-3',
            targetName: '.component-area--header'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should return instanceDefinitions that passes component level filters
      (the instanceDefinitions componentDefinition.passesFilter should return true)', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByComponentLevelFilters instanceDefinitions

        assert.equal filteredInstanceDefinitions.length, 2
        assert.equal filteredInstanceDefinitions[0].get('id'), 'instance-2'
        assert.equal filteredInstanceDefinitions[1].get('id'), 'instance-3'

      it 'should call componentDefinition.passesFilter once fore each instance
      that reference that componentDefinition and pass the filterModel and
      globalConditionsModel', ->
        componentDefinitions = componentManager._componentDefinitionsCollection.models
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal componentDefinitions.length, 3
        assert.equal instanceDefinitions.length, 3

        for componentDefinition in componentDefinitions
          sandbox.spy componentDefinition, 'passesFilter'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByComponentLevelFilters instanceDefinitions

        for componentDefinition in componentDefinitions
          assert componentDefinition.passesFilter.calledWith componentManager._filterModel, componentManager._globalConditionsModel

        assert.equal componentDefinitions[0].passesFilter.returnValues[0], false
        assert.equal componentDefinitions[1].passesFilter.returnValues[0], true
        assert.equal componentDefinitions[2].passesFilter.returnValues[0], true



    describe '_filterInstanceDefinitionsByInstanceLevelFilters', ->
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
            targetName: '.component-area--header',
            conditions: ->
              return false
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: '.component-area--header'
            conditions: ->
              return true
          },
          {
            id: 'instance-3',
            componentId: 'mock-component',
            targetName: '.component-area--header'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should return instanceDefinitions that passes instanceLevel filters
      (the instanceDefinitions passesFilter should return true)', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByInstanceLevelFilters instanceDefinitions

        assert.equal filteredInstanceDefinitions.length, 2
        assert.equal filteredInstanceDefinitions[0].get('id'), 'instance-2'
        assert.equal filteredInstanceDefinitions[1].get('id'), 'instance-3'

      it 'should call instanceDefinition.passesFilter once fore each instanceDefinition
      and pass the filterModel and globalConditionsModel', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        for instanceDefinition in instanceDefinitions
          sandbox.spy instanceDefinition, 'passesFilter'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByInstanceLevelFilters instanceDefinitions

        for instanceDefinition in instanceDefinitions
          assert instanceDefinition.passesFilter.calledWith componentManager._filterModel, componentManager._globalConditionsModel

        assert.equal instanceDefinitions[0].passesFilter.returnValues[0], false
        assert.equal instanceDefinitions[1].passesFilter.returnValues[0], true
        assert.equal instanceDefinitions[2].passesFilter.returnValues[0], true



    describe '_filterInstanceDefinitionsByCustomProperties', ->
      componentSettings =
        components: [
          {
            id: 'mock-component',
            src: '../test/spec/MockComponent',
            type: 'my-custom-type'
          }
        ]
        instances: [
          {
            id: 'instance-1',
            componentId: 'mock-component',
            targetName: '.component-area--header',
            color: 'green'
          },
          {
            id: 'instance-2',
            componentId: 'mock-component',
            targetName: '.component-area--header'
          },
          {
            id: 'instance-3',
            componentId: 'mock-component',
            targetName: '.component-area--header',
            type: 'my-custom-instance-type'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

      it 'should call _componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition
      once for every instanceDefinition', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        getComponentDefinitionByInstanceDefinitionSpy = sandbox.spy componentManager._componentDefinitionsCollection, 'getComponentDefinitionByInstanceDefinition'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions

        assert.equal instanceDefinitions.length, 3
        assert getComponentDefinitionByInstanceDefinitionSpy.calledThrice


      it 'should call _componentDefinition.getCustomProperties once for every instanceDefinition', ->
        componentDefinitions = componentManager._componentDefinitionsCollection.models
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal componentDefinitions.length, 1
        assert.equal instanceDefinitions.length, 3

        getCustomPropertiesSpy = sandbox.spy componentDefinitions[0], 'getCustomProperties'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions

        assert.equal instanceDefinitions.length, 3
        assert getCustomPropertiesSpy.calledThrice

      it 'should call _instanceDefinition.getCustomProperties once for every instanceDefinition', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        for instanceDefinition in instanceDefinitions
          sandbox.spy instanceDefinition, 'getCustomProperties'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions

        assert.equal instanceDefinitions.length, 3
        for instanceDefinition in instanceDefinitions
          assert instanceDefinition.getCustomProperties.calledOnce


      it 'should call _filterModel.getCustomProperties once', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        sandbox.spy componentManager._filterModel, 'getCustomProperties'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions

        assert.equal instanceDefinitions.length, 3
        assert componentManager._filterModel.getCustomProperties.calledOnce

      it 'should ignore custom properties on both componentDefinitions and instanceDefinitions
      if there are no custom properties on the filterModel', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions

        assert.equal instanceDefinitions.length, 3

      it 'should return instanceDefinitions that matches custom properties
      defined on a component level', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        componentManager._filterModel.set
          type: 'my-custom-type'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions
        assert.equal filteredInstanceDefinitions.length, 2
        assert.equal filteredInstanceDefinitions[0].get('id'), 'instance-1'
        assert.equal filteredInstanceDefinitions[1].get('id'), 'instance-2'

        # the thired instance definition over ride the type property and will
        # therefore not match the filter
        # assert.equal filteredInstanceDefinitions[2].get('id'), 'instance-3'

      it 'should return instanceDefinitions that matches custom properties
      defined on a instance level', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        componentManager._filterModel.set
          color: 'green'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions
        assert.equal filteredInstanceDefinitions.length, 1
        assert.equal filteredInstanceDefinitions[0].get('id'), 'instance-1'

      it 'should return instanceDefinitions that overrides custom properties
      on a component level', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        componentManager._filterModel.set
          type: 'my-custom-instance-type'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions
        assert.equal filteredInstanceDefinitions.length, 1
        assert.equal filteredInstanceDefinitions[0].get('id'), 'instance-3'

      it 'should return no instanceDefinitions if filtering on a property that is
      not defined on either componentDefinitions or instanceDefinitions', ->
        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        assert.equal instanceDefinitions.length, 3

        componentManager._filterModel.set
          nonExistingProperty: 'nonExistingValue'

        filteredInstanceDefinitions = componentManager._filterInstanceDefinitionsByCustomProperties instanceDefinitions
        assert.equal filteredInstanceDefinitions.length, 0



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
              targetName: '.component-area--header',
              showCount: 4
            },
            {
              id: 'instance-2',
              componentId: 'mock-component',
              targetName: 'component-area--main',
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
            targetName: '.component-area--header'
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
            targetName: 'body'
            urlPattern: 'foo/:bar'
          }
          {
            id: 'instance-2',
            componentId: 'mock-iframe-component',
            targetName: 'body'
            urlPattern: 'bar/:foo'
          }
        ]

      beforeEach ->
        componentManager.initialize componentSettings

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
          iframeAttributes:
            height: 100
            border: 0

        componentManager._componentDefinitionsCollection.models[0].attributes.args = componentArgs
        componentManager._instanceDefinitionsCollection.models[0].attributes.args = instanceArgs

        componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
        instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

        result = componentManager._getInstanceArguments instanceDefinition, componentDefinition

        assert.deepEqual result, expectedResults

      it 'should add src as an attribute on the args object if the component is an IframeComponent', ->
        args =
          foo: 'bar'

        expectedResults =
          foo: 'bar'
          src: 'http://www.github.com'

        componentManager._componentDefinitionsCollection.models[1].attributes.args = args

        componentManager.refresh().then =>
          componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-iframe-component'
          instanceDefinition = componentManager._instanceDefinitionsCollection.models[1]

          result = componentManager._getInstanceArguments instanceDefinition, componentDefinition

          assert.equal result.foo, expectedResults.foo
          assert.equal result.src, expectedResults.src

      it 'should not add src as an attribute on the args object if the component is not an IframeComponent', ->
        args =
          foo: 'bar'

        expectedResults =
          foo: 'bar'

        componentManager._componentDefinitionsCollection.models[0].attributes.args = args

        componentManager.refresh().then =>
          componentDefinition = componentManager._componentDefinitionsCollection.get 'mock-component'
          instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]

          result = componentManager._getInstanceArguments instanceDefinition, componentDefinition

          assert.equal result.foo, expectedResults.foo
          assert.equal result.src, undefined



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

      it 'should remove any undefined values from the array returned', ->
        compactSpy = sandbox.spy _, 'compact'
        createNewInstancesIfUndefined = false

        instanceDefinitions = componentManager._instanceDefinitionsCollection.models
        instances = componentManager._mapInstances instanceDefinitions, createNewInstancesIfUndefined
        # in this case this array would have been containing two undefined values 
        # unless we called _.compact
        assert.equal instances.length, 0
        assert compactSpy.called



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
            targetName: '.component-area--header'
            urlPattern: 'foo/:bar'
            order: 1
            args:
              id: 'instance-1'
          }
        ]

      componentManager.initialize componentSettings
      instanceDefinition = componentManager._instanceDefinitionsCollection.models[0]



    describe '_onActiveInstanceAdd', ->

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
              id: 'instance-1'
              componentId: 'mock-component'
              targetName: 'body'
            }
          ]

        componentManager.initialize componentSettings

      it 'should call incrementShowCount on the instanceDefinition correlating to
      the  added activeInstanceDefinition', ->
        instanceDefinition = componentManager._instanceDefinitionsCollection.get 'instance-1'
        activeInstanceDefinitions = componentManager._createActiveInstanceDefinitionObjects instanceDefinition
        incrementShowCountSpy = sandbox.spy instanceDefinition, 'incrementShowCount'
        do componentManager.refresh
        assert incrementShowCountSpy.called


    describe '_onMessageReceived', ->
      settings =
        listenForMessages: true
        componentSettings:
          components: [
            {
              id: 'mock-iframe-component'
              src: 'http://www.github.com'
            }
          ]
          instances: [
            {
              id: 'instance-1'
              componentId: 'mock-component'
              targetName: 'body'
            }
          ]


      it 'should be called if a message is recieved', ->
        data =
          id: 'instance-1'
          message: 'im a message'

        onMessageReceivedSpy = sandbox.spy componentManager, '_onMessageReceived'
        componentManager.initialize settings

        window.postMessage data

        assert onMessageReceivedSpy.called

      it 'should throw an MESSAGE.MISSING_ID error if the event.data is missing
      an id', ->

        event =
          data:
            message: 'data is missing an id'

        errorFn = -> componentManager._onMessageReceived event
        assert.throws (-> errorFn()), /The id of targeted instance must be passed as first argument/

      it 'should throw an MESSAGE.MISSING_MESSAGE error if the event.data is
      missing a message', ->

        event =
          data:
            id: 'data is missing a message'

        errorFn = -> componentManager._onMessageReceived event
        assert.throws (-> errorFn()), /No message was passed/

      it 'should call postMessageToInstance with the id and the message (data)
      from the event', ->
        postMessageToInstanceStub = sandbox.stub componentManager, 'postMessageToInstance'
        event =
          data:
            id: 'im the id'
            message: 'im the message'

        componentManager._onMessageReceived event
        assert postMessageToInstanceStub.calledWith event.data.id, event.data.message