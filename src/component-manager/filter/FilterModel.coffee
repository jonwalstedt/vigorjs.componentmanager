class FilterModel extends Backbone.Model

  defaults:
    url: undefined
    filterString: undefined
    includeIfStringMatches: undefined
    excludeIfStringMatches: undefined
    hasToMatchString: undefined
    cantMatchString: undefined
    dryRun: false

  parse: (attrs) ->

    if attrs?.url is ""
      url = ""
    else
      url = attrs?.url or @get('url') or undefined

    newValues =
      url: url
      filterString: attrs?.filterString or undefined
      includeIfStringMatches: attrs?.includeIfStringMatches or undefined
      excludeIfStringMatches: attrs?.excludeIfStringMatches or undefined
      hasToMatchString: attrs?.hasToMatchString or undefined
      cantMatchString: attrs?.cantMatchString or undefined
      dryRun: attrs?.dryRun or false

    return newValues


