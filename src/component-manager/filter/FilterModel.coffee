class FilterModel extends Backbone.Model

  defaults:
    url: undefined
    conditions: undefined
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
      conditions: attrs?.conditions or @get('conditions') or undefined
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined

    return newValues


