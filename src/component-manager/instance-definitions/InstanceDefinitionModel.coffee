class InstanceDefinitionModel extends Backbone.Model

  ERROR:
    VALIDATION:
      ID_UNDEFINED: 'id cant be undefined'
      ID_NOT_A_STRING: 'id should be a string'
      ID_IS_EMPTY_STRING: 'id can not be an empty string'
      COMPONENT_ID_UNDEFINED: 'componentId cant be undefined'
      COMPONENT_ID_NOT_A_STRING: 'componentId should be a string'
      COMPONENT_ID_IS_EMPTY_STRING: 'componentId can not be an empty string'
      TARGET_NAME_UNDEFINED: 'targetName cant be undefined'

    MISSING_GLOBAL_CONDITIONS: 'No global conditions was passed, condition could not be tested'

    MISSING_RENDER_METHOD: (id) ->
      return "The instance for #{id} does not have a render method"

    MISSING_CONDITION: (condition) ->
      return "Trying to verify condition #{condition} but it has not been registered yet"


  defaults:
    id: undefined
    componentId: undefined
    args: undefined
    order: undefined
    targetName: undefined
    instance: undefined
    showCount: 0
    urlParams: undefined
    urlParamsModel: undefined
    reInstantiateOnUrlParamChange: false

    # filterproperties
    filterString: undefined
    # includeIfFilterStringMatches: undefined
    filterStringHasToMatch: undefined
    filterStringCantMatch: undefined
    conditions: undefined
    maxShowCount: undefined
    urlPattern: undefined

  validate: (attrs, options) ->
    unless attrs.id
      throw @ERROR.VALIDATION.ID_UNDEFINED

    unless _.isString(attrs.id)
      throw @ERROR.VALIDATION.ID_NOT_A_STRING

    unless /^.*[^ ].*$/.test(attrs.id)
      throw @ERROR.VALIDATION.ID_IS_EMPTY_STRING

    unless attrs.componentId
      throw @ERROR.VALIDATION.COMPONENT_ID_UNDEFINED

    unless _.isString(attrs.componentId)
      throw @ERROR.VALIDATION.COMPONENT_ID_NOT_A_STRING

    unless /^.*[^ ].*$/.test(attrs.componentId)
      throw @ERROR.VALIDATION.COMPONENT_ID_IS_EMPTY_STRING

    unless attrs.targetName
      throw @ERROR.VALIDATION.TARGET_NAME_UNDEFINED

  isAttached: ->
    instance = @get 'instance'
    attached = false
    return attached unless instance

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
      throw @ERROR.MISSING_RENDER_METHOD @get('id')

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
    if instance?.dispose?
      do instance.dispose
    instance = undefined
    @set
      'instance': undefined
    , silent: true

  passesFilter: (filter, globalConditions) ->
    if filter?.url or filter?.url is ''
      urlMatch = @doesUrlPatternMatch(filter.url)
      if urlMatch?
        if urlMatch is true
          @addUrlParams filter.url
        else
          return false

    if @get('conditions')
      areConditionsMet = @areConditionsMet globalConditions, filter
      if areConditionsMet?
        return false unless areConditionsMet

    if filter?.filterString
      # not needed?
      # if includeIfMatch = @includeIfFilterStringMatches(filter.filterString)
      #   return includeIfMatch

      hasToMatch = @filterStringHasToMatch filter.filterString
      if hasToMatch?
        return hasToMatch

      cantMatch = @filterStringCantMatch filter.filterString
      if cantMatch?
        return cantMatch

    if filter?.includeIfStringMatches
      filterStringMatch = @includeIfStringMatches filter.includeIfStringMatches
      if filterStringMatch?
        return filterStringMatch

    if filter?.hasToMatchString
      return @hasToMatchString filter.hasToMatchString

    if filter?.cantMatchString
      return @cantMatchString filter.cantMatchString

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
    return !!@includeIfStringMatches filterString

  cantMatchString: (filterString) ->
    return not @hasToMatchString filterString

  includeIfStringMatches: (filterString) ->
    filter = @get 'filterString'
    if filter
      return !!filter.match filterString

  # includeIfFilterStringMatches: (filterString) ->
  #   filter = @get 'includeIfFilterStringMatches'
  #   if filter
  #     return !!filterString?.match filter

  filterStringHasToMatch: (filterString) ->
    filter = @get 'filterStringHasToMatch'
    if filter
      return !!filterString?.match filter

  filterStringCantMatch: (filterString) ->
    unless filterString then return false
    filter = @get 'filterStringCantMatch'
    if filter
      return not !!filterString?.match filter

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

  areConditionsMet: (globalConditions, filter) ->
    instanceConditions = @get 'conditions'
    shouldBeIncluded = true

    if instanceConditions
      unless _.isArray(instanceConditions)
        instanceConditions = [instanceConditions]

      for condition in instanceConditions
        if _.isFunction(condition) and not condition(filter, @get('args'))
          shouldBeIncluded = false
          break

        else if _.isString(condition)
          unless globalConditions
            throw @ERROR.MISSING_GLOBAL_CONDITIONS

          unless globalConditions[condition]?
            throw @ERROR.MISSING_CONDITION condition

          shouldBeIncluded = globalConditions[condition](filter, @get('args'))
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

    if matchingUrlParams.length > 0
      urlParamsModel.set matchingUrlParams[0]

      @set
        'urlParams': matchingUrlParams
      , silent: not @get('reInstantiateOnUrlParamChange')

