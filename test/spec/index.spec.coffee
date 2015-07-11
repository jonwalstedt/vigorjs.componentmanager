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

  render: ->
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
window.MockComponent2 = MockComponent

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
    it 'should call _serialize', ->
      serializeStub = sandbox.stub componentManager, 'serialize'
      do componentManager.serialize
      assert serializeStub.called

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
            'id': 'mock-component',
            'src': 'window.MockComponent'
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
            'id': 'mock-component',
            'src': 'window.MockComponent'
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
              'id': 'mock-component',
              'src': 'window.MockComponent'
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
    it 'should not remove old conditions', ->
    it 'should update existing conditions', ->

  describe 'addComponent', ->
    it 'should validate incoming component data', ->
    it 'should parse incoming component data', ->
    it 'should store incoming component data', ->
    it 'should not remove old components', ->

  describe 'addInstance', ->
    it 'should validate incoming instance data', ->
    it 'should parse incoming instance data', ->
    it 'should store incoming instance data', ->
    it 'should not remove old instances', ->

  describe 'updateComponent', ->
    it 'should validate incomming component data'
    it 'should update a specific component with new data', ->

  describe 'updateInstances', ->
    it 'should validate incomming instance data'
    it 'should update one or multiple instances with new data', ->

  describe 'removeComponent', ->
    it 'should remove a specific component', ->

  describe 'removeInstance', ->
    it 'should remove a specific instance', ->

  describe 'setContext', ->
    it 'should save the passed context', ->
    it 'should save the passed context as a jQuery object if passing a string (using the string as a selector)', ->

  describe 'setComponentClassName', ->
    it 'should save the componentClassName', ->

  describe 'setTargetPrefix', ->
    it 'should store the target prefix'

  describe 'getContext', ->

  describe 'getComponentClassName', ->

  describe 'getTargetPrefix', ->
    it 'should return a specified prefix or the default prefix', ->

  describe 'getActiveFilter', ->
    it 'should return currently applied filters', ->

  describe 'getConditions', ->
    it 'return current conditions', ->

  describe 'getComponentById', ->
    it 'should get a JSON representation of the data for a specific component', ->

  describe 'getInstanceById', ->
    it 'should get a JSON representation of the data for one specific instance', ->

  describe 'getComponents', ->
    it 'shuld return an array of all registered components', ->

  describe 'getInstances', ->
    it 'should return all instances (even those not currently active)', ->

  describe 'getActiveInstances', ->
    it 'should return all instances that mataches the current filter', ->


