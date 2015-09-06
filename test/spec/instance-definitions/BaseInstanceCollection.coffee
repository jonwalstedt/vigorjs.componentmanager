assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly
BaseInstanceCollection = __testOnly.BaseInstanceCollection
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel

describe 'A BaseInstanceCollection', ->

  collection = undefined
  beforeEach ->
    collection = new BaseInstanceCollection [
      { id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, { id: 3, data: 'Data3'}
    ]

  describe 'getInstanceDefinition', ->
    it 'should call get with passed id', ->
      getSpy = sinon.spy collection, 'get'
      id = 2
      collection.getInstanceDefinition id
      assert getSpy.calledWith id

    it 'if no instanceDefinition can be found with the provided id it should thro an UNKNOWN_INSTANCE_DEFINITION error', ->
      id = 4
      errorFn = -> collection.getInstanceDefinition id
      assert.throws (-> errorFn()), collection.ERROR.UNKNOWN_INSTANCE_DEFINITION

    it 'should return the instanceDefinition', ->
      id = 1
      model = collection.getInstanceDefinition id
      assert.equal model.get('id'), id
      assert model instanceof InstanceDefinitionModel
