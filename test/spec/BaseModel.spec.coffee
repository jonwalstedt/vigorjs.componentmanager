assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../dist/vigorjs.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly

BaseModel = __testOnly.BaseModel

class MockModel extends BaseModel
  defaults:
    foo: undefined
    bar: undefined

describe 'BaseModel', ->
  model = undefined
  beforeEach ->
    model = new BaseModel()

  afterEach ->
    model = undefined

  describe 'getCustomProperties', ->
    it 'should return all current properties that is not part of the defaults
    object', ->
      model = new MockModel
        foo: 'fooVal'
        bar: 'barVal'
        baz: 'bazVal'

      expectedResult =
        baz: 'bazVal'

      result = model.getCustomProperties()
      assert.deepEqual result, expectedResult

    it 'should ignore properties with undefined values if ignorePropertiesWithUndefinedValues 
    is not set to false', ->
      model = new MockModel
        foo: 'fooVal'
        bar: 'barVal'
        baz: 'bazVal'
        qux: undefined

      expectedResult =
        baz: 'bazVal'

      ignorePropertiesWithUndefinedValues = true

      result = model.getCustomProperties ignorePropertiesWithUndefinedValues
      assert.deepEqual result, expectedResult

    it 'should not ignore properties with undefined values if
    ignorePropertiesWithUndefinedValues is set to true (default)', ->
      model = new MockModel
        foo: 'fooVal'
        bar: 'barVal'
        baz: 'bazVal'
        qux: undefined

      expectedResult =
        baz: 'bazVal'
        qux: undefined

      ignorePropertiesWithUndefinedValues = false

      result = model.getCustomProperties ignorePropertiesWithUndefinedValues
      assert.deepEqual result, expectedResult
