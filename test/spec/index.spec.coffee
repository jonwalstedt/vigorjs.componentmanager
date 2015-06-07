assert = require 'assert'
sinon = require 'sinon'
Vigor = require('../../dist/vigor.componentmanager')

componentManager = Vigor.componentManager
__testOnly = componentManager.__testOnly

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

    it 'should call _parse - since its private the call cant be tracked, instead we verify that we get the expected results of parse', ->
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
    it 'should call _parse - since its private the call cant be tracked, instead we verify that we get the expected results of parse', ->
      settings =
        targetPrefix: 'dummy-prefix'

      expectedResults = settings.targetPrefix

      defaultPrefix = componentManager.getTargetPrefix()
      assert.equal defaultPrefix, 'component-area'

      componentManager.initialize settings
      results = componentManager.getTargetPrefix()

      assert.equal results, expectedResults

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

  describe 'serialize', ->
    it 'should serialize the data used by the componentManager into a format that it can read', ->

      expectedResults =
        conditions: {}
        components: []
        hidden: []
        instanceDefinitions: []

  describe 'addComponent', ->
    it 'should validate incoming component data', ->
    it 'should parse incoming component data', ->
    it 'should store incoming component data', ->
    it 'should not remove old components', ->

  describe 'updateComponent', ->
    it 'should validate incomming component data'
    it 'should update a specific component with new data', ->

  describe 'removeComponent', ->
    it 'should remove a specific component', ->

  describe 'getComponentById', ->
    it 'should get a JSON representation of the data for a specific component', ->

  describe 'getComponents', ->
    it 'shuld return an array of all registered components', ->

  describe 'addInstance', ->
    it 'should validate incoming instance data', ->
    it 'should parse incoming instance data', ->
    it 'should store incoming instance data', ->
    it 'should not remove old instances', ->

  describe 'updateInstances', ->
    it 'should validate incomming instance data'
    it 'should update one or multiple instances with new data', ->

  describe 'removeInstance', ->
    it 'should remove a specific instance', ->

  describe 'getInstanceById', ->
    it 'should get a JSON representation of the data for one specific instance', ->

  describe 'getInstances', ->
    it 'should return all instances (even those not currently active)', ->

  describe 'getActiveInstances', ->
    it 'should return all active instances', ->

  describe 'getTargetPrefix', ->
    it 'should return a specified prefix or the default prefix', ->

  describe 'registerConditions', ->
    it 'should register new conditions', ->
    it 'should not remove old conditions', ->
    it 'should update existing conditions', ->

  describe 'getConditions', ->
    it 'return current conditions', ->

  describe 'clear', ->
    it 'should remove all components', ->
    it 'should remove all instances', ->
    it 'should remove all activeComponents', ->
    it 'should remove all filters', ->
    it 'should remove all conditions', ->

  describe 'dispose', ->
    it 'should call clear', ->

