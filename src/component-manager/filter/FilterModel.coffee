class FilterModel extends BaseModel

  defaults:
    url: undefined
    filterString: undefined
    includeIfMatch: undefined
    excludeIfMatch: undefined
    hasToMatch: undefined
    cantMatch: undefined

    options:
      add: true
      remove: true
      merge: true
      invert: false
      forceFilterStringMatching: false

  parse: (attrs) ->
    @clear silent: true
    props = _.extend {}, @defaults, attrs
    props.options = _.extend {}, @defaults.options, props.options
    return props

  serialize: (excludeOptions = true) ->
    if excludeOptions
      filter = _.omit @toJSON(), 'options'
    else
      filter = @toJSON()
    return JSON.stringify filter
