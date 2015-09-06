assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'
mockComponents = require '../mockComponents'

__testOnly = Vigor.ComponentManager.__testOnly

ComponentDefinitionsCollection = __testOnly.ComponentDefinitionsCollection
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel

MockComponent = window.MockComponent = mockComponents.MockComponent
MockComponent2 = window.MockComponent2 = mockComponents.MockComponent2

describe 'ComponentDefinitionsCollection', ->
  sandbox = undefined
  componentDefinitionsCollection = undefined
  instanceDefinition = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()
    instanceProps =
      id: 'instance-1',
      componentId: 'mock-component-2',
      targetName: 'test-prefix--header'
      urlPattern: 'foo/:bar'

    componentDefinitions = [
      {
        id: 'mock-component-1',
        src: 'window.MockComponent1'
      }
      {
        id: 'mock-component-2',
        src: 'window.MockComponent2'
      }
      {
        id: 'mock-component-3',
        src: 'window.MockComponent3'
      }
    ]

    instanceDefinition = new InstanceDefinitionModel instanceProps
    componentDefinitionsCollection = new ComponentDefinitionsCollection componentDefinitions

  afterEach ->
    do sandbox.restore

  describe 'getComponentClassByInstanceDefinition', ->
    it 'should call getComponentDefinitionByInstanceDefinition and pass the instanceDefinition', ->
      getComponentDefinitionByInstanceDefinitionSpy = sandbox.spy componentDefinitionsCollection, 'getComponentDefinitionByInstanceDefinition'
      componentDefinitionsCollection.getComponentClassByInstanceDefinition instanceDefinition
      assert getComponentDefinitionByInstanceDefinitionSpy.calledWith instanceDefinition

    it 'should call getClass on the componentDefinition', ->
      requestedInstanceDefinition = componentDefinitionsCollection.at 1
      getClassSpy = sandbox.spy requestedInstanceDefinition, 'getClass'

      componentDefinitionsCollection.getComponentClassByInstanceDefinition instanceDefinition
      assert getClassSpy.called

    it 'should return the requested class defined in the componentDefinition', ->
      requestedClass = componentDefinitionsCollection.getComponentClassByInstanceDefinition instanceDefinition
      assert.equal requestedClass, window.MockComponent2

  describe 'getComponentDefinitionByInstanceDefinition', ->
    it 'should call getComponentDefinitionById and pass the componentId from passed instanceDefinition', ->
      getComponentDefinitionByIdSpy = sandbox.spy componentDefinitionsCollection, 'getComponentDefinitionById'
      componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      assert getComponentDefinitionByIdSpy.calledWith instanceDefinition.get('componentId')

    it 'should return the requested componentDefinition', ->
      requestedComponentDefinition = componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      assert.deepEqual requestedComponentDefinition, componentDefinitionsCollection.at(1)
      assert.equal requestedComponentDefinition.get('id'), 'mock-component-2'

  describe 'getComponentDefinitionById', ->
    it 'should call get with the passed componentId', ->
      getSpy = sandbox.spy componentDefinitionsCollection, 'get'
      componentDefinitionsCollection.getComponentDefinitionById 'mock-component-2'
      assert getSpy.calledWith 'mock-component-2'

    it 'should throw an UNKNOWN_COMPONENT_DEFINITION error if no componentDefinition was found', ->
      errorFn = -> componentDefinitionsCollection.getComponentDefinitionById 'non-existing-component-id'
      assert.throws (-> errorFn()), componentDefinitionsCollection.ERROR.UNKNOWN_COMPONENT_DEFINITION

    it 'should return the componentDefinition if it was found', ->
      requestedComponentDefinition = componentDefinitionsCollection.getComponentDefinitionById 'mock-component-2'
      assert.deepEqual requestedComponentDefinition, componentDefinitionsCollection.at(1)
      assert.equal requestedComponentDefinition.get('id'), 'mock-component-2'



