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
    if attrs?.url is ""
      url = ""
    else
      url = attrs?.url or undefined

    if attrs?.options?
      options = _.extend @getFilterOptions(), attrs?.options
    else
      options = @getFilterOptions()

    newValues =
      url: url
      filterString: attrs?.filterString or undefined
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      excludeIfStringMatches: attrs?.excludeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined
      options: options

    return newValues

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

