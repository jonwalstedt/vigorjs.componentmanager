class InstanceDefinitionModel extends Backbone.Model

  defaults:
    id: undefined
    componentId: undefined
    filter: undefined
    conditions: undefined
    args: undefined
    order: undefined
    targetName: undefined
    instance: undefined
    showCount: 0
    urlPattern: undefined
    urlParams: undefined
    urlParamsModel: undefined
    reInstantiateOnUrlParamChange: false

  validate: (attrs, options) ->
    unless attrs.id
      throw 'id cant be undefined'

    unless _.isString(attrs.id)
      throw 'id should be a string'

    unless /^.*[^ ].*$/.test(attrs.id)
      throw 'id can not be an empty string'

    unless attrs.componentId
      throw 'componentId cant be undefined'

    unless _.isString(attrs.componentId)
      throw 'componentId should be a string'

    unless /^.*[^ ].*$/.test(attrs.componentId)
      throw 'componentId can not be an empty string'

    unless attrs.targetName
      throw 'targetName cant be undefined'

  isAttached: ->
    instance = @get 'instance'
    attached = false
    if instance
      attached = $.contains document.body, instance.el
    return attached

  incrementShowCount: (silent = true) ->
    showCount = @get 'showCount'
    showCount++
    @set
      'showCount': showCount
    , silent: silent

  renderInstance: ->
    instance = @get 'instance'
    unless instance then return
    unless instance.render
      throw "The enstance #{instance.get('id')} does not have a render method"

    if instance.preRender? and _.isFunction(instance.preRender)
      do instance.preRender

    do instance.render

    if instance.postrender? and _.isFunction(instance.postRender)
      do instance.postRender

  dispose: ->
    instance = @get 'instance'
    if instance
      do instance.dispose
      do @clear

  disposeAndRemoveInstance: ->
    instance = @get 'instance'
    do instance?.dispose
    instance = undefined
    @set
      'instance': undefined
    , silent: true

  passesFilter: (filter) ->
    if filter.route or filter.route is ''
      urlMatch = @doesUrlPatternMatch(filter.route)
      if urlMatch?
        if urlMatch is true
          @addUrlParams filter.route
        else
          return false

    if filter.filterString
      filterStringMatch = @doesFilterStringMatch(filter.filterString)
      if filterStringMatch?
        return false unless filterStringMatch

    if @get('conditions')
      areConditionsMet = @areConditionsMet filter.conditions
      if areConditionsMet?
        return false unless areConditionsMet
    return true

  doesFilterStringMatch: (filterString) ->
    filter = @get 'filter'
    if filter
      return filterString.match new RegExp(filter)

  doesUrlPatternMatch: (route) ->
    match = false
    urlPattern = @get 'urlPattern'
    if urlPattern
      unless _.isArray(urlPattern)
        urlPattern = [urlPattern]

      for pattern in urlPattern
        routeRegEx = router._routeToRegExp pattern
        match = routeRegEx.test route
        if match then return match
      return match
    else
      return undefined

  areConditionsMet: (globalConditions) ->
    instanceConditions = @get 'conditions'
    shouldBeIncluded = true

    if instanceConditions
      unless _.isArray(instanceConditions)
        instanceConditions = [instanceConditions]

      for condition in instanceConditions
        if _.isFunction(condition) and not condition()
          shouldBeIncluded = false
          break

        else if _.isString(condition)
          unless globalConditions
            throw 'No global conditions was passed, condition could not be tested'
          shouldBeIncluded = globalConditions[condition]()
          if not shouldBeIncluded
            break

    return shouldBeIncluded

  addUrlParams: (route) ->
    urlParams = router.getArguments @get('urlPattern'), route
    urlParams.route = route

    urlParamsModel = @get 'urlParamsModel'
    urlParamsModel.set urlParams

    @set
      'urlParams': urlParams
    , silent: not @get('reInstantiateOnUrlParamChange')

