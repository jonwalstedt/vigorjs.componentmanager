assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../dist/vigor.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly

clock = undefined
collection = undefined

describe 'A BaseCollection', ->

  beforeEach ->
    collection = new __testOnly.BaseCollection()
    clock = sinon.useFakeTimers()

  afterEach ->
    clock.restore()

  describe 'should aggregate changes to collection', ->
    it 'and send THROTTLED_ADD on add events in collection', ->
      collectionAddTriggerCounter = 0
      backboneAddTriggerCounter = 0
      addedModels = []

      collection.on 'add', ->
        backboneAddTriggerCounter++

      collection.on collection.THROTTLED_ADD, (added) ->
        collectionAddTriggerCounter++
        addedModels = added

      collection.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]

      clock.tick 49
      assert.equal backboneAddTriggerCounter, 2
      assert.equal collectionAddTriggerCounter, 0

      clock.tick 50
      assert.equal backboneAddTriggerCounter, 2
      assert.equal collectionAddTriggerCounter, 1
      assert.equal addedModels.length, 2

    it 'and send THROTTLED_REMOVE on remove events in collection', ->
      collectionRemoveTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      removedModels = []

      collection.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]
      clock.tick 50

      collection.on 'remove', ->
        backboneRemoveTriggerCounter++

      collection.on collection.THROTTLED_REMOVE, (removed) ->
        collectionRemoveTriggerCounter++
        removedModels = removed

      collection.set [{ id: 2, data: 'Data2'}]
      clock.tick 100

      assert.equal backboneRemoveTriggerCounter, 2
      assert.equal collectionRemoveTriggerCounter, 1
      assert.equal collection.models.length, 1
      assert.equal removedModels.length, 2

    it 'and send THROTTLED_CHANGE on change events in collection', ->
      collectionChangeTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      changedModels = []

      collection.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]

      clock.tick 50
      collection.on 'change', ->
        backboneChangeTriggerCounter++

      collection.on collection.THROTTLED_CHANGE, (changed) ->
        collectionChangeTriggerCounter++
        changedModels = changed

      collection.set [{ id: 1, data: 'Data12'}, { id: 2, data: 'Data22'}, { id: 3, data: 'Data3'}]

      clock.tick 100

      assert.equal collectionChangeTriggerCounter, 1
      assert.equal backboneChangeTriggerCounter, 2
      assert.equal collection.models.length, 3
      assert.equal changedModels.length, 2

    it 'and send THROTTLED_DIFF on changes in collection (add, remove, change)', ->
      collectionDiffTriggerCounter = 0
      backboneChangeTriggerCounter = 0
      backboneAddTriggerCounter = 0
      backboneRemoveTriggerCounter = 0
      diffObj = {}

      collection.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}, {id: 3, data: 'Data3'}]
      clock.tick 50

      collection.on 'change', () ->
        backboneChangeTriggerCounter++

      collection.on 'add', () ->
        backboneAddTriggerCounter++

      collection.on 'remove', () ->
        backboneRemoveTriggerCounter++

      collection.on collection.THROTTLED_DIFF, (aggregatedChanges) ->
        collectionDiffTriggerCounter++
        diffObj = aggregatedChanges

      collection.set [
        { id: 1, data: 'Data1'} # unchanged item
        { id: 2, data: 'Data22'} # updated value in item
        # { id: 3, data: 'Data3'}, removed item since it's not part of new data set
        { id: 4, data: 'Data4'} # added item
        { id: 5, data: 'Data5'} # added item
      ]

      clock.tick 100

      assert.equal collectionDiffTriggerCounter, 1
      assert.equal backboneChangeTriggerCounter, 1
      assert.equal backboneRemoveTriggerCounter, 1
      assert.equal backboneAddTriggerCounter, 2
      assert.equal collection.models.length, 4
      assert.equal diffObj.added.length, 2
      assert.equal diffObj.changed.length, 1
      assert.equal diffObj.removed.length, 1
      assert.equal diffObj.consolidated.length, 3

  describe 'when using helper methods', ->
    it 'isEmpty should tell if the collection is empty or not', ->
      empty = collection.isEmpty()
      assert.equal empty, true

      collection.set { id: 1, data: 'Data1'}

      empty = collection.isEmpty()
      assert.equal empty, false

    it 'getByIds should return an array of models when given an array of ids', ->
      collection.set [{ id: 1, data: 'Data1'}, { id: 2, data: 'Data2'}]
      models = collection.getByIds([1, 2])
      assert.deepEqual models[0].attributes, { id: 1, data: 'Data1'}
      assert.deepEqual models[1].attributes, { id: 2, data: 'Data2'}
