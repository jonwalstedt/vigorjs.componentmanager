assert = require 'assert'
Vigor = require '../../../dist/vigor.componentmanager'
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

  describe 'parse', ->
    it 'should not keep already set url value if no new one is passed', ->
      filterOptions =
        url: 'foo/bar'
        hasToMatch: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.url, filterOptions.url

      filterModel.set filterModel.parse({hasToMatch: 'bar'})
      assert.equal filterModel.attributes.url, undefined

    it 'should not keep already set "includeIfMatch" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        includeIfMatch: 'foo bar'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.includeIfMatch, filterOptions.includeIfMatch

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.includeIfMatch, undefined

    it 'should not keep already set "hasToMatch" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        hasToMatch: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.hasToMatch, filterOptions.hasToMatch

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.hasToMatch, undefined

    it 'should not keep already set "cantMatch" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        cantMatch: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.cantMatch, filterOptions.cantMatch

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.cantMatch, undefined

    it 'should return parsed values', ->
      filterOptions =
        url: 'foo'
        cantMatch: 'bar'

      filterModel = new FilterModel()

      results = filterModel.parse(filterOptions)
      assert.equal results.url, 'foo'
      assert.equal results.includeIfMatch, undefined
      assert.equal results.hasToMatch, undefined
      assert.equal results.cantMatch, 'bar'

  describe 'getFilterOptions', ->
    it 'should return default values unless the flags has been changed', ->
      filterModel = new FilterModel()
      defaultValues =
        add: true
        remove: true
        merge: true
        invert: false
        forceFilterStringMatching: false

      result = filterModel.getFilterOptions()
      assert.deepEqual result, defaultValues


    it 'should return changed values mixed with default values if some changed', ->
      filterModel = new FilterModel()
      changedValues =
        add: false

      expectedResults =
        add: false
        remove: true
        merge: true
        invert: false
        forceFilterStringMatching: false

      filterModel.set 'options', changedValues

      result = filterModel.getFilterOptions()
      assert.deepEqual result, expectedResults