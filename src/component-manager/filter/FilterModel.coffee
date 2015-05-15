class FilterModel extends Backbone.Model

  defaults:
    url: undefined
    includeIfStringMatches: undefined
    hasToMatchString: undefined
    cantMatchString: undefined
    conditions: undefined

  parse: (attrs) ->

    if attrs?.url is ""
      url = ""
    else
      url = attrs?.url or @get('url') or undefined

    newValues =
      url: url
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined
      conditions: attrs?.conditions or @get('conditions') or undefined

    return newValues


