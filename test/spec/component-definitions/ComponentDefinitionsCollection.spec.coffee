assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'
MockComponent = require '../MockComponent'
MockComponent2 = require '../MockComponent2'

__testOnly = Vigor.ComponentManager.__testOnly

ComponentDefinitionsCollection = __testOnly.ComponentDefinitionsCollection
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel


describe 'ComponentDefinitionsCollection', ->
  sandbox = undefined
  componentDefinitionsCollection = undefined
  instanceDefinition = undefined
  instanceDefinition2 = undefined
  instanceDefinitions = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()
    instanceProps =
      id: 'instance-1',
      componentId: 'mock-component-1',
      targetName: 'test-prefix--header'
      urlPattern: 'foo/:bar'

    instanceProps2 =
      id: 'instance-2',
      componentId: 'mock-component-2',
      targetName: 'test-prefix--header'
      urlPattern: 'foo/:bar'

    componentDefinitions = [
      {
        id: 'mock-component-1',
        src: '../test/spec/MockComponent'
      }
      {
        id: 'mock-component-2',
        src: '../test/spec/MockComponent2'
      }
    ]

    instanceDefinition = new InstanceDefinitionModel instanceProps
    instanceDefinition2 = new InstanceDefinitionModel instanceProps2
    instanceDefinitions = [instanceDefinition, instanceDefinition2]
    componentDefinitionsCollection = new ComponentDefinitionsCollection componentDefinitions

  afterEach ->
    do sandbox.restore

  describe 'getComponentClassPromisesByInstanceDefinitions', ->


    it 'should call getComponentDefinitionByInstanceDefinition once for every instanceDefinition in passed array', ->
      getComponentDefinitionByInstanceDefinitionSpy = sandbox.spy componentDefinitionsCollection, 'getComponentDefinitionByInstanceDefinition'
      componentDefinitionsCollection.getComponentClassPromisesByInstanceDefinitions instanceDefinitions

      assert getComponentDefinitionByInstanceDefinitionSpy.calledTwice

      firstCall = getComponentDefinitionByInstanceDefinitionSpy.firstCall
      secondCall = getComponentDefinitionByInstanceDefinitionSpy.secondCall

      assert firstCall.calledWith instanceDefinition
      assert secondCall.calledWith instanceDefinition2

    it 'should call componentDefinition.getComponentClassPromise on every instanceDefinition in passed array', ->
      componentDefinition = componentDefinitionsCollection.get 'mock-component-1'
      componentDefinition2 = componentDefinitionsCollection.get 'mock-component-2'

      getComponentClassPromiseSpy = sandbox.spy componentDefinition, 'getComponentClassPromise'
      getComponentClassPromiseSpy2 = sandbox.spy componentDefinition2, 'getComponentClassPromise'

      componentDefinitionsCollection.getComponentClassPromisesByInstanceDefinitions instanceDefinitions

      assert getComponentClassPromiseSpy.called
      assert getComponentClassPromiseSpy2.called

    it 'should return an array with componentClassPromises (promises)', ->
      result = componentDefinitionsCollection.getComponentClassPromisesByInstanceDefinitions instanceDefinitions
      assert.equal result.length, 2
      assert _.isFunction(result[0].then)
      assert _.isFunction(result[1].then)

  describe 'getComponentClassPromiseByInstanceDefinition', ->
    it 'should call getComponentDefinitionByInstanceDefinition and pass the instanceDefinition', ->
      getComponentDefinitionByInstanceDefinitionSpy = sandbox.spy componentDefinitionsCollection, 'getComponentDefinitionByInstanceDefinition'
      componentDefinitionsCollection.getComponentClassPromiseByInstanceDefinition instanceDefinition
      assert getComponentDefinitionByInstanceDefinitionSpy.calledWith instanceDefinition

    it 'should call getClass on the componentDefinition', ->
      requestedInstanceDefinition = componentDefinitionsCollection.at 0
      getClassSpy = sandbox.spy requestedInstanceDefinition, 'getClass'

      componentDefinitionsCollection.getComponentClassPromiseByInstanceDefinition instanceDefinition
      assert getClassSpy.called

    it 'should return a componentClassPromise (promise)', ->
      result = componentDefinitionsCollection.getComponentClassPromiseByInstanceDefinition instanceDefinition
      assert _.isFunction(result.then)

  describe 'getComponentDefinitionByInstanceDefinition', ->
    it 'should call getComponentDefinitionById and pass the componentId from passed instanceDefinition', ->
      getComponentDefinitionByIdSpy = sandbox.spy componentDefinitionsCollection, 'getComponentDefinitionById'
      componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      assert getComponentDefinitionByIdSpy.calledWith instanceDefinition.get('componentId')

    it 'should return the requested componentDefinition', ->
      requestedComponentDefinition = componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      assert.deepEqual requestedComponentDefinition, componentDefinitionsCollection.at 0
      assert.equal requestedComponentDefinition.get('id'), 'mock-component-1'

  describe 'getComponentDefinitionById', ->
    it 'should call get with the passed componentId', ->
      getSpy = sandbox.spy componentDefinitionsCollection, 'get'
      componentDefinitionsCollection.getComponentDefinitionById 'mock-component-1'
      assert getSpy.calledWith 'mock-component-1'

    it 'should throw an UNKNOWN_COMPONENT_DEFINITION error if no componentDefinition was found', ->
      errorFn = -> componentDefinitionsCollection.getComponentDefinitionById 'non-existing-component-id'
      assert.throws (-> errorFn()), componentDefinitionsCollection.ERROR.UNKNOWN_COMPONENT_DEFINITION

    it 'should return the componentDefinition if it was found', ->
      requestedComponentDefinition = componentDefinitionsCollection.getComponentDefinitionById 'mock-component-1'
      assert.deepEqual requestedComponentDefinition, componentDefinitionsCollection.at 0
      assert.equal requestedComponentDefinition.get('id'), 'mock-component-1'



