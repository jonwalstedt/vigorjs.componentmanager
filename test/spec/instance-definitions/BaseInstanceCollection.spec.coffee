assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigorjs.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly
BaseCollection = __testOnly.BaseCollection
BaseInstanceCollection = __testOnly.BaseInstanceCollection
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel

describe 'A BaseInstanceCollection', ->

  collection = undefined
  sandbox = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()

  afterEach ->
    do sandbox.restore

  describe 'initialize', ->

    it 'should add a reset listener with _onReset as a callback', ->
      collection = new BaseInstanceCollection()
      onSpy = sandbox.spy collection, 'on'
      do collection.initialize
      assert onSpy.calledWith 'reset', collection._onReset

    it 'should call BaseCollection.prototype.initialize', ->
      collection = new BaseInstanceCollection()
      initializeSpy = sandbox.spy BaseCollection.prototype, 'initialize'
      do collection.initialize
      assert initializeSpy.called


  describe 'getInstanceDefinitionById', ->
    beforeEach ->
      collection = new BaseInstanceCollection [
        { id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, { id: 3, data: 'Data3'}
      ]

    it 'should call get with passed id', ->
      getSpy = sinon.spy collection, 'get'
      id = 2
      collection.getInstanceDefinitionById id
      assert getSpy.calledWith id

    it 'if no instanceDefinition can be found with the provided id it should thro an UNKNOWN_INSTANCE_DEFINITION error', ->
      id = 4
      errorFn = -> collection.getInstanceDefinitionById id
      assert.throws (-> errorFn()), collection.ERROR.UNKNOWN_INSTANCE_DEFINITION

    it 'should return the instanceDefinition', ->
      id = 1
      model = collection.getInstanceDefinitionById id
      assert.equal model.get('id'), id
      assert model instanceof InstanceDefinitionModel

  describe '_onReset', ->
    it 'should call dispose on all previous models', ->
      spies = []

      collection = new BaseInstanceCollection [
        { id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, { id: 3, data: 'Data3'}
      ]

      for model in collection.models
        spies.push sandbox.spy model, 'dispose'

      do collection.reset

      for spy in spies
        assert spy.called

