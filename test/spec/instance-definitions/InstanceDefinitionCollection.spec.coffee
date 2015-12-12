assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

InstanceDefinitionsCollection = __testOnly.InstanceDefinitionsCollection
FilterModel = __testOnly.FilterModel

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
            'targetName': '.my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target2',
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
            'targetName': '.my-prefix--target1',
            'urlPattern': 'global'

        expectedResults =
          'id': 'instance-1',
          'componentId': 'component-id-1',
          'urlPattern': ['*notFound', '*action'],
          'targetName': '.my-prefix--target1',
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
            'targetName': '.my-prefix--target1',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-2',
            'componentId': 'component-id-2',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target2',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-3',
            'componentId': 'component-id-3',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target3',
            'urlParamsModel': new DummyModel()
          },
          {
            'id': 'instance-4',
            'componentId': 'component-id-4',
            'urlPattern': ['*notFound', '*action'],
            'targetName': '.my-prefix--target4',
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
            'targetName': '.my-prefix--target1',
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
          'targetName': '.my-prefix--target1',
          'urlParamsModel': new DummyModel()
        },
        {
          'id': 'instance-2',
          'componentId': 'component-id-2',
          'urlPattern': ['*notFound', '*action'],
          'targetName': '.my-prefix--target2',
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
        'targetName': '.foo--target1',
        'componentId': 'component-id-1',

      expectedResults =
        'id': 'instance-1',
        'targetName': '.foo--target1',
        'componentId': 'component-id-1',
        'urlParamsModel': new DummyModel()

      parsedData = instanceDefinitionsCollection.parseInstanceDefinition instanceDefinition
      assert.deepEqual parsedData, expectedResults

    it 'should convert the urlPattern "global" to an array with *notFound and *action', ->
      instanceDefinition =
        'id': 'instance-1',
        'targetName': '.foo--target1',
        'componentId': 'component-id-1',
        'urlPattern': 'global'

      expectedResults =
        'id': 'instance-1',
        'targetName': '.foo--target1',
        'componentId': 'component-id-1',
        'urlPattern': ['*notFound', '*action'],
        'urlParamsModel': new DummyModel()

      parsedData = instanceDefinitionsCollection.parseInstanceDefinition instanceDefinition
      assert.deepEqual parsedData, expectedResults




  describe '_formatTargetName', ->
    it 'should not modify the selector if it is "body"', ->
      targetName = 'body'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, 'body'

    it 'should add a dot (class indicator) and the targetPrefix to targetName if
    it does not already have it', ->
      targetName = 'my-target'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, '.my-prefix--my-target'

    it 'should add a dot (class indicator) to prefixed target names if it
    does not already have it', ->
      targetName = 'my-prefix--my-target'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, '.my-prefix--my-target'

    it 'should add the prefix to class selector that do not have it', ->
      targetName = '.my-target'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, '.my-prefix--my-target'

    it 'should not add an extra prefix to class selector that do have it', ->
      targetName = '.my-prefix--my-target'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, '.my-prefix--my-target'

    it 'should just return the targetName if it is a jquery object', ->
      $('body').append '<div class="dummy"></div>'
      targetName = $ '.dummy'
      targetPrefix = 'my-prefix'
      result = instanceDefinitionsCollection._formatTargetName targetName, targetPrefix
      assert.equal result, targetName
      do targetName.remove

