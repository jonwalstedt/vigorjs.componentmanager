assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

InstanceDefinitionsCollection = __testOnly.InstanceDefinitionsCollection

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

  describe 'parse', ->
    describe 'if data is an object', ->
      it 'should be able to parse an object with targets as keys and an array of instance definiton objects as values', ->
        data =
          targetPrefix: 'my-prefix'
          instanceDefinitions: {
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
            'targetName': 'my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target2',
            'urlParamsModel': new DummyModel()
          }
        ]

        parsedData = instanceDefinitionsCollection.parse data
        assert.deepEqual parsedData, expectedResults

      it 'should be able to parse a single instance definition object', ->
        data =
          targetPrefix: 'my-prefix'
          instanceDefinitions:
            'id': 'instance-1',
            'componentId': 'component-id-1',
            'targetName': 'my-prefix--target1',
            'urlPattern': 'global'

        expectedResults =
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'urlPattern': ['*notFound', '*action'],
          'targetName': 'my-prefix--target1',
          'urlParamsModel': new DummyModel()

        parsedData = instanceDefinitionsCollection.parse data
        assert.deepEqual parsedData, expectedResults

    describe 'if data is an array', ->
      it 'should be able to parse an array of instanceDefinition objects', ->
        data =
          targetPrefix: 'my-prefix',
          instanceDefinitions: [
            {
              'id': 'instance-1',
              'targetName': 'my-prefix--target1',
              'componentId': 'component-id-1',
              'urlPattern': 'global'
            },
            {
              'id': 'instance-2',
              'targetName': 'my-prefix--target2',
              'componentId': 'component-id-2',
              'urlPattern': 'global'
            },
            {
              'id': 'instance-3',
              'targetName': 'my-prefix--target3',
              'componentId': 'component-id-3',
              'urlPattern': 'global'
            },
            {
              'id': 'instance-4',
              'targetName': 'my-prefix--target4',
              'componentId': 'component-id-4',
              'urlPattern': 'global'
            }
          ]

        expectedResults = [
          {
            'id': 'instance-1',
            'componentId': 'component-id-1',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target3',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': 'my-prefix--target4',
            'urlParamsModel': new DummyModel()
          }
        ]

        parsedData = instanceDefinitionsCollection.parse data
        assert.deepEqual parsedData, expectedResults

    it 'should add prefix to targetName if it is missing', ->
      data =
        targetPrefix: 'my-prefix',
        instanceDefinitions: [
          {
            'id': 'instance-1',
            'targetName': 'my-prefix--target1',
            'componentId': 'component-id-1',
            'urlPattern': 'global'
          },
          {
            'id': 'instance-2',
            'targetName': 'target2',
            'componentId': 'component-id-2',
            'urlPattern': 'global'
          }
        ]

      expectedResults = [
        {
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'urlPattern': ['*notFound', '*action'],
          'targetName': 'my-prefix--target1',
          'urlParamsModel': new DummyModel()
        },
        {
          'id': 'instance-2',
          'componentId': 'component-id-2',
          'urlPattern': ['*notFound', '*action'],
          'targetName': 'my-prefix--target2',
          'urlParamsModel': new DummyModel()
        }
      ]

      parsedData = instanceDefinitionsCollection.parse data
      assert.deepEqual parsedData, expectedResults

    it 'should not add prefix to targetName if it is "body"', ->
      data =
        targetPrefix: 'my-prefix',
        instanceDefinitions: [
          {
            'id': 'instance-1',
            'targetName': 'body',
            'componentId': 'component-id-1',
            'urlPattern': 'global'
          }
        ]

      expectedResults = [
        {
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'urlPattern': ['*notFound', '*action'],
          'targetName': 'body',
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
    describe 'should return instanceDefinitions that matches passed filter', ->

      beforeEach ->
        data =
          targetPrefix: 'foo',
          instanceDefinitions: [
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

      it 'should return instanceDefinitions that matches the passed url', ->
        filter = url: 'foo'
        globalConditions =
          foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter, globalConditions

        # two global components and one that matches the url in the filter
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-2'
        assert.equal filteredInstances[2].get('id'), 'instance-3'

      it 'should return instanceDefinitions that passes a condition check', ->
        globalConditions =
          foo: -> return false

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions undefined, globalConditions

        # all components except the one with a falsy condition
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-3'
        assert.equal filteredInstances[2].get('id'), 'instance-4'

      it 'should only return instanceDefinitions that has a filterString that matches the string defined in hasToMatchString', ->
        filter =
          hasToMatchString: 'foo'

        globalConditions =
          foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter, globalConditions

        # only the component matching the string foo
        assert.equal filteredInstances.length, 1
        assert.equal filteredInstances[0].get('id'), 'instance-1'

      it 'should return instanceDefinitions that has a filterString that matches the string defined in includeIfStringMatches and instanceDefinitions that doesnt have a filterString defined', ->
        filter =
          includeIfStringMatches: 'bar'

        globalConditions =
          foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter, globalConditions

        # one component matching the string and the component that doesn't have any filterString defined
        assert.equal filteredInstances.length, 2
        assert.equal filteredInstances[0].get('id'), 'instance-2'
        assert.equal filteredInstances[1].get('id'), 'instance-4'

      it 'should return instanceDefinitions that has a filterString that doesnt matches the string defined in excludeIfStringMatches and instanceDefinitions that doesnt have a filterString defined', ->
        filter =
          excludeIfStringMatches: 'bar'

        globalConditions =
          foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter, globalConditions

        # one component matching the string and the component that doesn't have any filterString defined
        assert.equal filteredInstances.length, 3
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-3'
        assert.equal filteredInstances[2].get('id'), 'instance-4'

      it 'should return instanceDefinitions that has a filterString that doesnt matches the string defined in includeIfStringMatches', ->
        filter =
          cantMatchString: 'bar'

        globalConditions =
          foo: -> return true

        filteredInstances = instanceDefinitionsCollection.getInstanceDefinitions filter, globalConditions

        # all components except the one with bar defined as a filterString
        assert.equal filteredInstances.length, 2
        assert.equal filteredInstances[0].get('id'), 'instance-1'
        assert.equal filteredInstances[1].get('id'), 'instance-3'

  describe 'addUrlParams', ->
    it 'should call addUrlParams and pass along the url to all instanceDefinitionModels passed to the method', ->
      data = 
        targetPrefix: 'foo'
        instanceDefinitions: [
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

