class FilterModel extends Backbone.Model

  defaults:
    url: undefined
    filterString: undefined
    includeIfStringMatches: undefined
    excludeIfStringMatches: undefined
    hasToMatchString: undefined
    cantMatchString: undefined

    options:
      add: true
      remove: true
      merge: true
      invert: false

  parse: (attrs) ->
    @clear silent: true
    props = _.extend {}, @defaults, attrs
    props.options = _.extend @getFilterOptions(), props.options
    return props

  getFilterOptions: ->
    filter = @toJSON()
    add = true
    remove = true
    merge = true
    invert = false

    if filter?.options?.add?
      add = filter?.options?.add

    if filter?.options?.remove?
      remove = filter?.options?.remove

    if filter?.options?.merge?
      merge = filter?.options?.merge

    if filter?.options?.invert?
      invert = filter?.options?.invert

    options =
      add: add
      remove: remove
      merge: merge
      invert: invert

    return options

