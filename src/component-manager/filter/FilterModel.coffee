class FilterModel extends Backbone.Model

  defaults:
    url: undefined
    filterString: undefined
    includeIfStringMatches: undefined
    hasToMatchString: undefined
    cantMatchString: undefined

  parse: (attrs) ->

    if attrs?.url is ""
      url = ""
    else
      url = attrs?.url or @get('url') or undefined

    newValues =
      url: url
      filterString: attrs?.filterString or undefined
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined

    return newValues


