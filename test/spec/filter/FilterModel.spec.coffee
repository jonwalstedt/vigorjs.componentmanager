assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigorjs.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly

FilterModel = __testOnly.FilterModel

describe 'FilterModel', ->
  describe 'default values', ->
    filterModel = new FilterModel()

    assert.equal filterModel.attributes.url, undefined
    assert.equal filterModel.attributes.includeIfMatch, undefined
    assert.equal filterModel.attributes.excludeIfMatch, undefined
    assert.equal filterModel.attributes.hasToMatch, undefined
    assert.equal filterModel.attributes.cantMatch, undefined
    assert.equal filterModel.attributes.conditions, undefined

    assert.equal filterModel.attributes.options.add, true
    assert.equal filterModel.attributes.options.remove, true
    assert.equal filterModel.attributes.options.merge, true
    assert.equal filterModel.attributes.options.invert, false
    assert.equal filterModel.attributes.options.forceFilterStringMatching, false

  describe 'parse', ->
    it 'should call clear and pass silent: true', ->
      filterModel = new FilterModel()
      silentOption =
        silent: true

      clearSpy = sinon.spy filterModel, 'clear'
      filterModel.parse()
      assert clearSpy.calledWith silentOption

    it 'should return new values merged with default values', ->
      filterOptions =
        url: 'foo'
        cantMatch: 'bar'

      filterModel = new FilterModel()

      results = filterModel.parse(filterOptions)
      assert.equal results.url, 'foo'
      assert.equal results.filterString, undefined
      assert.equal results.includeIfMatch, undefined
      assert.equal results.excludeIfMatch, undefined
      assert.equal results.hasToMatch, undefined
      assert.equal results.cantMatch, 'bar'
      assert.deepEqual filterModel.defaults.options, results.options

  describe 'serialize', ->
    it 'should return a serialized version of the current filter', ->
      filterOptions =
        url: 'foo'
        filterString: 'my string'
        includeIfMatch: 'bar'
        excludeIfMatch: 'baz'
        hasToMatch: 'qux'
        cantMatch: 'norf'
        options:
          invert: true

      filterModel = new FilterModel()
      filterModel.set filterModel.parse(filterOptions)
      result = filterModel.serialize()
      expectedResult = '{"url":"foo","filterString":"my string","includeIfMatch":"bar","excludeIfMatch":"baz","hasToMatch":"qux","cantMatch":"norf"}'

      assert.equal result, expectedResult

    it 'should return a serialized version of the current filter with options
    if excludeOptions is set to false', ->
      filterOptions =
        url: 'foo'
        filterString: 'my string'
        includeIfMatch: 'bar'
        excludeIfMatch: 'baz'
        hasToMatch: 'qux'
        cantMatch: 'norf'
        options:
          invert: true

      filterModel = new FilterModel()
      filterModel.set filterModel.parse(filterOptions)
      excludeOptions = false
      result = filterModel.serialize(excludeOptions)
      expectedResult = '{"url":"foo","filterString":"my string","includeIfMatch":"bar","excludeIfMatch":"baz","hasToMatch":"qux","cantMatch":"norf","options":{"add":true,"remove":true,"merge":true,"invert":true,"forceFilterStringMatching":false}}'
      assert.equal result, expectedResult
