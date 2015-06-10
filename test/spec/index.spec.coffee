assert = require 'assert'
sinon = require 'sinon'
Vigor = require('../../dist/vigor.componentmanager')

componentManager = Vigor.componentManager
__testOnly = componentManager.__testOnly

class MockComponent
  $el: undefined
  constructor: ->
    @$el = $ '<div clas="mock-component"></div>'

  render: ->
    return @

window.MockComponent = MockComponent

describe 'The componentManager', ->
  sandbox = undefined

  beforeEach ->
    do componentManager.initialize
    sandbox = sinon.sandbox.create()

  afterEach ->
    do componentManager.dispose
    do sandbox.restore

  describe 'initialize', ->

    it 'should extend underscore events', ->
      extendSpy = sandbox.spy _, 'extend'
      do componentManager.initialize
      assert extendSpy.called

    it 'should call addListeners', ->
      addListeners = sandbox.spy componentManager, 'addListeners'
      do componentManager.initialize
      assert addListeners.called

    it 'should parse (covered by updateSettings test, this is just a quick test)', ->
      settings =
        targetPrefix: 'dummy-prefix'

      expectedResults = settings.targetPrefix

      defaultPrefix = componentManager.getTargetPrefix()
      assert.equal defaultPrefix, 'component-area'

      componentManager.initialize settings
      results = componentManager.getTargetPrefix()

      assert.equal results, expectedResults

    it 'should return the componentManager for chainability', ->
      cm = componentManager.initialize()
      assert.equal cm, componentManager

  describe 'updateSettings', ->
    it 'should parse and use passed settings', ->
      $('body').append "<div class='test'></div>"
      settings =
        componentClassName: 'test-class-name'
        $context: '.test'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: {
            testCondition: 'my-condition-reference-to-global-conditions'
          }
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

      defaults =
        componentClassName: 'vigor-component'
        $context: 'body'
        targetPrefix: 'component-area'
        componentSettings:
          conditions: {}
          hidden: []
          components: []
          instances: []

      results = componentManager.parse componentManager.serialize()
      assert.deepEqual results, defaults

      componentManager.initialize settings
      results = componentManager.parse componentManager.serialize()

      assert.equal results.componentClassName, 'test-class-name'
      assert.equal results.$context, '.test'
      assert.equal results.targetPrefix, 'test-prefix'
      assert.equal results.componentSettings.conditions.testCondition, 'my-condition-reference-to-global-conditions'
      assert.equal results.componentSettings.components.length, 1
      assert.equal results.componentSettings.hidden.length, 0
      assert.equal results.componentSettings.instances.length, 2
      assert.equal results.componentSettings.instances[0].reInstantiateOnUrlParamChange, false
      assert results.componentSettings.instances[0].urlParamsModel
      do $('.test').remove

    it 'should return the componentManager for chainability', ->
      cm = componentManager.updateSettings()
      assert.equal cm, componentManager

  describe 'refresh', ->
    it 'should update the active filter with parsed versions of passed options', ->
      filterOptions =
        url: 'foo'
        conditions: 'bar'
        hasToMatchString: 'baz'

      expectedResults =
        url: 'foo'
        conditions: 'bar'
        includeIfStringMatches: undefined
        hasToMatchString: 'baz'
        cantMatchString: undefined

      componentManager.refresh filterOptions
      results = componentManager.getActiveFilter()
      assert.deepEqual results, expectedResults

      filterOptions =
        url: 'foo'
        conditions: 'bar'
        includeIfStringMatches: 'baz'
        cantMatchString: 'qux'

      expectedResults =
        url: 'foo'
        conditions: 'bar'
        includeIfStringMatches: 'baz'
        hasToMatchString: undefined
        cantMatchString: 'qux'

      # note that includeIfStringMatches, hasToMatchString and cantMatchString resets
      # to default (undefined) by the filter parser even if it had a value the previous
      # time the filter got updated. This will only happen if their values are not present in
      # the passed object

      componentManager.refresh filterOptions
      results = componentManager.getActiveFilter()
      assert.deepEqual results, expectedResults

    it 'it should clear the filterModel if no filterOptions are passed', ->
      filterOptions =
        url: 'foo'
        conditions: 'bar'

      expectedResults =
        url: 'foo'
        conditions: 'bar'
        includeIfStringMatches: undefined
        hasToMatchString: undefined
        cantMatchString: undefined

      componentManager.refresh filterOptions
      results = componentManager.getActiveFilter()
      assert.deepEqual results, expectedResults

      expectedResults = {}
      componentManager.refresh()
      results = componentManager.getActiveFilter()
      assert.deepEqual results, expectedResults

    it 'should return the componentManager for chainability', ->
      cm = componentManager.refresh()
      assert.equal cm, componentManager

  describe 'serialize', ->
    it 'should serialize the data used by the componentManager into a format that it later can read using parse', ->
      settings =
        componentClassName: 'test-class-name'
        $context: $('<div class="test"></div>')
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions:
            dummyCondition: ->
              if 10 > 9 then return false
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

      expectedResults = '{\"$context\":\"div.test\",\"componentClassName\":\"test-class-name\",\"targetPrefix\":\"test-prefix\",\"componentSettings\":{\"conditions\":{\"dummyCondition\":\"function () {\\n                if (10 > 9) {\\n                  return false;\\n                }\\n              }\"},\"components\":[{\"id\":\"mock-component\",\"src\":\"window.MockComponent\"}],\"hidden\":[],\"instances\":[{\"id\":\"instance-1\",\"componentId\":\"mock-component\",\"targetName\":\"test-prefix--header\",\"urlParamsModel\":{},\"showCount\":0,\"reInstantiateOnUrlParamChange\":false},{\"id\":\"instance-2\",\"componentId\":\"mock-component\",\"targetName\":\"test-prefix--main\",\"urlParamsModel\":{},\"showCount\":0,\"reInstantiateOnUrlParamChange\":false}]}}'
      results = componentManager.initialize(settings).serialize()
      assert.equal results, expectedResults

  describe 'parse', ->
    settings =
      componentClassName: 'test-class-name'
      $context: $('<div class="test"></div>')
      targetPrefix: 'test-prefix'
      componentSettings:
        conditions: 'test-condition'
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
        conditions: 'test-condition'
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
      # clean out the added urlParamsModel (a backbone model with generated uniqe id since its id wont be predictable)
      for instance in results.componentSettings.instances
        delete instance.urlParamsModel

      assert.deepEqual results, expectedResults

    it 'should be able to parse settings that contains methods as condition', ->
      settings.componentSettings.conditions = dummyCondition: ->
        if 500 > 400 then return 30

      # do componentManager.dispose
      serializedResults = componentManager.initialize(settings).serialize()
      results = componentManager.parse serializedResults
      conditionResult = results.componentSettings.conditions.dummyCondition()

      # clean out the added urlParamsModel (a backbone model with generated uniqe id since its id wont be predictable)
      for instance in results.componentSettings.instances
        delete instance.urlParamsModel

      delete expectedResults.componentSettings.conditions
      delete results.componentSettings.conditions

      assert.deepEqual results, expectedResults
      assert.equal conditionResult, 30

  describe 'clear', ->
    beforeEach ->
      $('body').append '<div class="clear-test"></div>'
      $('.clear-test').append '<div class="test-prefix--header"></div>'

      settings =
        componentClassName: 'test-class-name'
        $context: '.clear-test'
        targetPrefix: 'test-prefix'
        componentSettings:
          conditions: 'test-condition'
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
        conditions: 'test-condition'
        includeIfStringMatches: undefined
        hasToMatchString: undefined
        cantMatchString: undefined

      assert.deepEqual filter, expectedResults

      do componentManager.clear
      filter = componentManager.getActiveFilter()
      expectedResults = {}

      filter = componentManager.getActiveFilter()
      assert.deepEqual filter, expectedResults

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
      sinon.spy componentManager, 'clear'
      do componentManager.dispose
      assert componentManager.clear.called

    it 'should call removeListeners', ->
      sinon.spy componentManager, 'removeListeners'
      do componentManager.dispose
      assert componentManager.removeListeners.called

  describe 'addListeners', ->

  describe 'registerConditions', ->
    it 'should register new conditions', ->
      # obj = 'test-condition'
      # componentManager.registerConditions obj


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


