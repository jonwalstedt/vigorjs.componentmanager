assert = require 'assert'
sinon = require 'sinon'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
InstanceDefinitionsCollection = componentManager.__testOnly.InstanceDefinitionsCollection

class DummyModel
  set: ->
  get: ->

describe 'InstanceDefinitionsCollection', ->
  instanceDefinitionsCollection = undefined
  stubbedModel = undefined

  beforeEach ->
    instanceDefinitionsCollection = new InstanceDefinitionsCollection()
    stubbedModel = sinon.stub Backbone, 'Model', DummyModel

  afterEach ->
    stubbedModel.restore()

  describe 'setTargetPrefix', ->
    it 'should store passed prefix on the instance', ->
      instanceDefinitionsCollection.setTargetPrefix 'my-prefix'
      assert.equal instanceDefinitionsCollection.targetPrefix, 'my-prefix'

  describe 'parse', ->
    describe 'if data is an object', ->
      it 'should be able to parse an object with targets as keys and an array of instance definiton objects as values', ->
        data = {
          'target1': [
            {
              'id': 'instance-1',
              'componentId': 'component-id-1',
              'urlPattern': 'global'
            },
            {
              'id': 'instance-2',
              'componentId': 'component-id-2',
              'urlPattern': 'global'
            }
          ]
          'target2': [
            {
              'id': 'instance-3',
              'componentId': 'component-id-3',
              'urlPattern': 'global'
            },
            {
              'id': 'instance-4',
              'componentId': 'component-id-4',
              'urlPattern': 'global'
            }
          ]
        }

        expectedResults = [
          {
            'id': 'instance-1',
            'componentId': 'component-id-1',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target2',
            'urlParamsModel': new DummyModel()
          }
        ]

        instanceDefinitionsCollection.setTargetPrefix 'foo'
        parsedData = instanceDefinitionsCollection.parse data

        assert.deepEqual parsedData, expectedResults

      it 'should be able to parse a single instance definition object', ->
        data =
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'targetName': 'foo--target1',
          'urlPattern': 'global'

        expectedResults =
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'urlPattern': ['*notFound', '*action'],
          'targetName': 'foo--target1',
          'urlParamsModel': new DummyModel()

        parsedData = instanceDefinitionsCollection.parse data
        assert.deepEqual parsedData, expectedResults

    describe 'if data is an array', ->
      it 'should be able to parse an array of instance defnition objects', ->

        data = [
          {
            'id': 'instance-1',
            'targetName': 'foo--target1',
            'componentId': 'component-id-1',
            'urlPattern': 'global'
          },
          {
            'id': 'instance-2',
            'targetName': 'foo--target2',
            'componentId': 'component-id-2',
            'urlPattern': 'global'
          },
          {
            'id': 'instance-3',
            'targetName': 'foo--target3',
            'componentId': 'component-id-3',
            'urlPattern': 'global'
          },
          {
            'id': 'instance-4',
            'targetName': 'foo--target4',
            'componentId': 'component-id-4',
            'urlPattern': 'global'
          }
        ]

        expectedResults = [
          {
            'id': 'instance-1',
            'componentId': 'component-id-1',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target3',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'foo--target4',
            'urlParamsModel': new DummyModel()
          }
        ]

        parsedData = instanceDefinitionsCollection.parse data
        assert.deepEqual parsedData, expectedResults

  describe 'parseInstanceDefinition', ->
    it 'should add a new Backbone.Model as urlParamsModel', ->
      instanceDefinition =
        'id': 'instance-1',
        'targetName': 'foo--target1',
        'componentId': 'component-id-1',

      expectedResults =
        'id': 'instance-1',
        'targetName': 'foo--target1',
        'componentId': 'component-id-1',
        'urlParamsModel': new DummyModel()

      parsedData = instanceDefinitionsCollection.parseInstanceDefinition instanceDefinition
      assert.deepEqual parsedData, expectedResults

    it 'should convert the urlPattern "global" to an array with *notFound and *action', ->
      instanceDefinition =
        'id': 'instance-1',
        'targetName': 'foo--target1',
        'componentId': 'component-id-1',
        'urlPattern': 'global'

      expectedResults =
        'id': 'instance-1',
        'targetName': 'foo--target1',
        'componentId': 'component-id-1',
        'urlPattern': ['*notFound', '*action'],
        'urlParamsModel': new DummyModel()

      parsedData = instanceDefinitionsCollection.parseInstanceDefinition instanceDefinition
      assert.deepEqual parsedData, expectedResults

  describe 'getInstanceDefinitions', ->
    describe 'should return instanceDefintions that matches passed filter', ->

      beforeEach ->
        data = [
          {
            'id': 'instance-1',
            'targetName': 'foo--target1',
            'componentId': 'component-id-1',
            'urlPattern': 'global',
            'filterString': 'foo'
          },
          {
            'id': 'instance-2',
            'targetName': 'foo--target2',
            'componentId': 'component-id-2',
            'urlPattern': 'global',
            'filterString': 'bar',
            'conditions': 'foo'
          },
          {
            'id': 'instance-3',
            'targetName': 'foo--target3',
            'componentId': 'component-id-3',
            'urlPattern': 'foo',
            'filterString': 'baz'
          },
          {
            'id': 'instance-4',
            'targetName': 'foo--target4',
            'componentId': 'component-id-4',
            'urlPattern': 'bar'
          }
        ]

        instanceDefinitionsCollection.set data,
          parse: true
          validate: true
          remove: false

      it 'should return instanceDefintions that matches the passed url', ->
        filter =
          url: 'foo'
          conditions:
            foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

        # two global components and one that matches the url in the filter
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-2'
        assert.equal filteredInstances[2].get('id'), 'instance-3'

      it 'should return instanceDefintions that passes a condition check', ->
        filter =
          conditions:
            foo: -> return false

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

        # all components except the one with a falsy condition
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-3'
        assert.equal filteredInstances[2].get('id'), 'instance-4'

      it 'should only return instanceDefintions that has a filterString that matches the string defined in hasToMatchString', ->
        filter =
          hasToMatchString: 'foo'
          conditions:
            foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

        # only the component matching the string foo
        assert.equal filteredInstances.length, 1
        assert.equal filteredInstances[0].get('id'), 'instance-1'

      it 'should return instanceDefintions that has a filterString that matches the string defined in includeIfStringMatches and instanceDefintions that doesnt have a filterString defined', ->
        filter =
          includeIfStringMatches: 'bar'
          conditions:
            foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

        # one component matching the string and the component that doesn't have any filterString defined
        assert.equal filteredInstances.length, 2
        assert.equal filteredInstances[0].get('id'), 'instance-2'
        assert.equal filteredInstances[1].get('id'), 'instance-4'


      it 'should return instanceDefintions that has a filterString that doesnt matches the string defined in includeIfStringMatches and instanceDefintions that doesnt have a filterString defined', ->
        filter =
          cantMatchString: 'bar'
          conditions:
            foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

        # all components except the one with bar defined as a filterString
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-3'
        assert.equal filteredInstances[2].get('id'), 'instance-4'


  describe 'addUrlParams', ->
    it 'should call addUrlParams and pass along the url to all instanceDefinitionModels passed to the method', ->
      data = [
        {
          'id': 'instance-1',
          'targetName': 'foo--target1',
          'componentId': 'component-id-1',
          'urlPattern': 'global',
          'filterString': 'foo'
        },
        {
          'id': 'instance-2',
          'targetName': 'foo--target2',
          'componentId': 'component-id-2',
          'urlPattern': 'global',
          'filterString': 'bar',
          'conditions': -> return true
        },
        {
          'id': 'instance-3',
          'targetName': 'foo--target3',
          'componentId': 'component-id-3',
          'urlPattern': 'foo',
          'filterString': 'baz'
        },
        {
          'id': 'instance-4',
          'targetName': 'foo--target4',
          'componentId': 'component-id-4',
          'urlPattern': 'bar'
        }
      ]

      instanceDefinitionsCollection.set data,
        parse: true
        validate: true
        remove: false

      url = 'a-url-that-only-the-components-with-a-global-url-pattern-will-match'
      filter = url: url
      filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter

      for instance in filteredInstances
        sinon.spy instance, 'addUrlParams'

      # all global components
      assert.equal filteredInstances.length, 2
      instanceDefinitionsCollection.addUrlParams filteredInstances, url
      for instance in filteredInstances
        assert instance.addUrlParams.calledWith(url)

