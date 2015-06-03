class InstanceDefinitionModel extends Backbone.Model

  defaults:
    id: undefined
    componentId: undefined
    filterString: undefined
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

    if not instance.el and instance.$el
      el = instance.$el.get(0)
    else
      el = instance.el

    if instance
      attached = $.contains document.body, el
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
      throw "The instance #{instance.get('id')} does not have a render method"

    if instance.preRender? and _.isFunction(instance.preRender)
      do instance.preRender

    do instance.render

    if instance.postRender? and _.isFunction(instance.postRender)
      do instance.postRender

  dispose: ->
    instance = @get 'instance'
    if instance
      do instance.dispose
      do @clear

  disposeInstance: ->
    instance = @get 'instance'
    do instance?.dispose
    instance = undefined
    @set
      'instance': undefined
    , silent: true

  passesFilter: (filter) ->
    if filter?.url or filter?.url is ''
      urlMatch = @doesUrlPatternMatch(filter.url)
      if urlMatch?
        if urlMatch is true
          @addUrlParams filter.url
        else
          return false

    if @get('conditions')
      areConditionsMet = @areConditionsMet filter?.conditions
      if areConditionsMet?
        return false unless areConditionsMet

    if filter?.includeIfStringMatches
      filterStringMatch = @includeIfStringMatches(filter.includeIfStringMatches)
      if filterStringMatch?
        return filterStringMatch

    if filter?.hasToMatchString
      return @hasToMatchString(filter.hasToMatchString)

    if filter?.cantMatchString
      return @cantMatchString(filter.cantMatchString)

    return true

  exceedsMaximumShowCount: (componentMaxShowCount) ->
    showCount = @get 'showCount'
    maxShowCount = @get 'maxShowCount'
    exceedsShowCount = false

    unless maxShowCount
      maxShowCount = componentMaxShowCount

    if maxShowCount
      if showCount > maxShowCount
        exceedsShowCount = true

    return exceedsShowCount

  hasToMatchString: (filterString) ->
    return !!@includeIfStringMatches(filterString)

  cantMatchString: (filterString) ->
    return not @hasToMatchString filterString

  includeIfStringMatches: (filterString) ->
    filter = @get 'filterString'
    if filter
      return !!filter.match filterString

  doesUrlPatternMatch: (url) ->
    match = false
    urlPattern = @get 'urlPattern'
    if urlPattern
      unless _.isArray(urlPattern)
        urlPattern = [urlPattern]

      for pattern in urlPattern
        routeRegEx = router.routeToRegExp pattern
        match = routeRegEx.test url
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

          unless globalConditions[condition]?
            throw "Trying to verify condition #{condition} but it has not been registered yet"

          shouldBeIncluded = globalConditions[condition]()
          if not shouldBeIncluded
            break

    return shouldBeIncluded

  addUrlParams: (url) ->
    # a properly setup instanceDefinition should never have multiple urlPatterns that matches
    # one and the same url, ex: the url foo/bar/baz would match both patterns
    # ["foo/:section/:id", "foo/*splat"] the correct way would be to select one of them
    # (probably the first) and then use the url property of the params if more parts of the
    # url are needed.
    # To keep it simple we only update the urlParamsModel with the first matchingUrlParams
    # the entire array of matchingUrlParams is passed as an argument to the instance though.
    matchingUrlParams = router.getArguments @get('urlPattern'), url
    urlParamsModel = @get 'urlParamsModel'

    unless urlParamsModel
      urlParamsModel = new Backbone.Model()
      @set
        'urlParamsModel': urlParamsModel
      , silent: true

    urlParamsModel.set matchingUrlParams[0]

    @set
      'urlParams': matchingUrlParams
    , silent: not @get('reInstantiateOnUrlParamChange')

