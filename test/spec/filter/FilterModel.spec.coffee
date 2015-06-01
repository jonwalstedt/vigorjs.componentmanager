assert = require 'assert'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
FilterModel = componentManager.__testOnly.FilterModel

describe 'FilterModel', ->
  describe 'default values', ->
    filterModel = new FilterModel()

    assert.equal filterModel.attributes.url, undefined
    assert.equal filterModel.attributes.includeIfStringMatches, undefined
    assert.equal filterModel.attributes.hasToMatchString, undefined
    assert.equal filterModel.attributes.cantMatchString, undefined
    assert.equal filterModel.attributes.conditions, undefined

  describe 'parse', ->

  it 'should keep already set url value if no new one is passed', ->
    filterOptions =
      url: 'foo/bar'
      hasToMatchString: 'foo'

    filterModel = new FilterModel()

    filterModel.set filterModel.parse(filterOptions)
    assert.equal filterModel.attributes.url, filterOptions.url

    filterModel.set filterModel.parse({hasToMatchString: 'bar'})
    assert.equal filterModel.attributes.url, filterOptions.url

  it 'should keep already set conditions if no new one is passed', ->
    filterOptions =
      conditions: ['foo', 'bar']
      hasToMatchString: 'foo'

    filterModel = new FilterModel()

    filterModel.set filterModel.parse(filterOptions)
    assert.equal filterModel.attributes.conditions, filterOptions.conditions

    filterModel.set filterModel.parse({hasToMatchString: 'bar'})
    assert.equal filterModel.attributes.conditions, filterOptions.conditions

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
      conditions: 'baz'

    filterModel = new FilterModel()

    results = filterModel.parse(filterOptions)
    assert.equal results.url, 'foo'
    assert.equal results.conditions, 'baz'
    assert.equal results.includeIfStringMatches, undefined
    assert.equal results.hasToMatchString, undefined
    assert.equal results.cantMatchString, 'bar'

  it 'should update values with url and conditions unchanged if other properties changes in the model', ->
    filterOptions =
      url: 'foo'
      cantMatchString: 'bar'
      conditions: 'baz'

    filterModel = new FilterModel()

    results = filterModel.parse(filterOptions)
    filterModel.set results
    assert.equal filterModel.attributes.url, 'foo'
    assert.equal filterModel.attributes.conditions, 'baz'
    assert.equal filterModel.attributes.includeIfStringMatches, undefined
    assert.equal filterModel.attributes.hasToMatchString, undefined
    assert.equal filterModel.attributes.cantMatchString, 'bar'

    filterOptions =
      hasToMatchString: 'bar'

    results = filterModel.parse(filterOptions)
    filterModel.set results
    assert.equal filterModel.attributes.url, 'foo'
    assert.equal filterModel.attributes.conditions, 'baz'
    assert.equal filterModel.attributes.includeIfStringMatches, undefined
    assert.equal filterModel.attributes.hasToMatchString, 'bar'
    assert.equal filterModel.attributes.cantMatchString, undefined
