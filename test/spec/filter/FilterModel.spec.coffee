assert = require 'assert'
Vigor = require '../../../dist/vigor.componentmanager'
__testOnly = Vigor.ComponentManager.__testOnly

FilterModel = __testOnly.FilterModel

describe 'FilterModel', ->
  describe 'default values', ->
    filterModel = new FilterModel()

    assert.equal filterModel.attributes.url, undefined
    assert.equal filterModel.attributes.includeIfStringMatches, undefined
    assert.equal filterModel.attributes.hasToMatchString, undefined
    assert.equal filterModel.attributes.cantMatchString, undefined
    assert.equal filterModel.attributes.conditions, undefined

  describe 'parse', ->
    it 'should not keep already set url value if no new one is passed', ->
      filterOptions =
        url: 'foo/bar'
        hasToMatchString: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.url, filterOptions.url

      filterModel.set filterModel.parse({hasToMatchString: 'bar'})
      assert.equal filterModel.attributes.url, undefined

    it 'should not keep already set "includeIfStringMatches" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        includeIfStringMatches: 'foo bar'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.includeIfStringMatches, filterOptions.includeIfStringMatches

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.includeIfStringMatches, undefined

    it 'should not keep already set "hasToMatchString" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        hasToMatchString: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.hasToMatchString, filterOptions.hasToMatchString

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.hasToMatchString, undefined

    it 'should not keep already set "cantMatchString" if no new one is passed', ->
      filterOptions =
        url: 'foo'
        cantMatchString: 'foo'

      filterModel = new FilterModel()

      filterModel.set filterModel.parse(filterOptions)
      assert.equal filterModel.attributes.cantMatchString, filterOptions.cantMatchString

      filterModel.set filterModel.parse({url: 'bar'})
      assert.equal filterModel.attributes.cantMatchString, undefined

    it 'should return parsed values', ->
      filterOptions =
        url: 'foo'
        cantMatchString: 'bar'

      filterModel = new FilterModel()

      results = filterModel.parse(filterOptions)
      assert.equal results.url, 'foo'
      assert.equal results.includeIfStringMatches, undefined
      assert.equal results.hasToMatchString, undefined
      assert.equal results.cantMatchString, 'bar'

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