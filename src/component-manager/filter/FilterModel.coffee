class FilterModel extends Backbone.Model

  defaults:
    route: undefined
    includeIfStringMatches: undefined
    hasToMatchString: undefined
    cantMatchString: undefined
    conditions: undefined

  parse: (attrs) ->

    if attrs?.route is ""
      route = ""
    else
      route = attrs?.route or @get('route') or undefined

    newValues =
      route: route
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined
      conditions: attrs?.conditions or @get('conditions') or undefined

    return newValues


