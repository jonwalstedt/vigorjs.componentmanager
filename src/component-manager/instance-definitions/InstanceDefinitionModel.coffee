class InstanceDefinitionModel extends BaseModel

  ERROR:
    VALIDATION:
      ID_UNDEFINED: 'id cant be undefined'
      ID_NOT_A_STRING: 'id should be a string'
      ID_IS_EMPTY_STRING: 'id can not be an empty string'
      COMPONENT_ID_UNDEFINED: 'componentId cant be undefined'
      COMPONENT_ID_NOT_A_STRING: 'componentId should be a string'
      COMPONENT_ID_IS_EMPTY_STRING: 'componentId can not be an empty string'
      TARGET_NAME_UNDEFINED: 'targetName cant be undefined'
      TARGET_WRONG_FORMAT: 'target should be a string or a jquery object'

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
    reInstantiate: false

    # Filter properties
    filterString: undefined
    includeIfFilterStringMatches: undefined
    excludeIfFilterStringMatches: undefined
    conditions: undefined
    maxShowCount: undefined
    urlPattern: undefined

    # Private
    instance: undefined
    showCount: 0
    urlParams: undefined
    urlParamsModel: undefined

  _lastFilter: undefined

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

    unless _.isString(attrs.targetName)
      unless attrs.targetName.jquery?
        throw @ERROR.VALIDATION.TARGET_WRONG_FORMAT

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

  passesFilter: (filterModel, globalConditionsModel) ->
    filter = filterModel?.toJSON() or {}
    globalConditions = globalConditionsModel?.toJSON() or {}

    if filter?.url or filter?.url is ''
      urlMatch = @doesUrlPatternMatch filter.url
      if urlMatch?
        if urlMatch is true
          @addUrlParams filter.url
        else
          return false

    if @get('conditions')
      areConditionsMet = @areConditionsMet filter, globalConditions
      if areConditionsMet?
        return false unless areConditionsMet

    if filter?.filterString
      if @get('includeIfFilterStringMatches')?
        filterStringMatch = @includeIfFilterStringMatches filter.filterString
        if filterStringMatch?
          return false unless filterStringMatch

      if @get('excludeIfFilterStringMatches')?
        filterStringMatch = @excludeIfFilterStringMatches filter.filterString
        if filterStringMatch?
          return false unless filterStringMatch

    if filter?.options?.forceFilterStringMatching
      if @get('filterString')? \
      and (not filter?.includeIfMatch? \
      and not filter?.excludeIfMatch? \
      and not filter?.hasToMatch? \
      and not filter?.cantMatch?)
        return false

    if filter?.includeIfMatch
      filterStringMatch = @includeIfMatch filter.includeIfMatch

      if filter?.options?.forceFilterStringMatching
        filterStringMatch = !!filterStringMatch

      if filterStringMatch?
        return false unless filterStringMatch

    if filter?.excludeIfMatch
      filterStringMatch = @excludeIfMatch filter.excludeIfMatch

      if filter?.options?.forceFilterStringMatching
        filterStringMatch = !!filterStringMatch

      if filterStringMatch?
        return false unless filterStringMatch

    if filter?.hasToMatch
      filterStringMatch = @hasToMatch filter.hasToMatch
      if filterStringMatch?
        return false unless filterStringMatch

    if filter?.cantMatch
      filterStringMatch = @cantMatch filter.cantMatch
      if filterStringMatch?
        return false unless filterStringMatch

    # If we have a filter change and want to reinstantiate instances that is
    # already active
    if @_lastFilter isnt JSON.stringify(filter) and @get('reInstantiate')
      @_lastFilter = JSON.stringify(filter)
      @trigger 'change:reInstantiate', @

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

  includeIfMatch: (regexp) ->
    filterString = @get 'filterString'
    if filterString
      return !!filterString.match regexp

  excludeIfMatch: (regexp) ->
    filterString = @get 'filterString'
    if filterString
      return not !!filterString.match regexp

  hasToMatch: (regexp) ->
    return !!@includeIfMatch regexp

  cantMatch: (regexp) ->
    return !!@excludeIfMatch regexp

  includeIfFilterStringMatches: (filterString) ->
    regexp = @get 'includeIfFilterStringMatches'
    if regexp
      return !!filterString?.match regexp

  excludeIfFilterStringMatches: (filterString) ->
    regexp = @get 'excludeIfFilterStringMatches'
    if regexp
      return not !!filterString?.match regexp

  doesUrlPatternMatch: (url) ->
    match = false
    urlPattern = @get 'urlPattern'
    if urlPattern?
      unless _.isArray(urlPattern)
        urlPattern = [urlPattern]

      for pattern in urlPattern
        routeRegEx = router.routeToRegExp pattern
        match = routeRegEx.test url
        if match then return match
      return match
    else
      return undefined

  areConditionsMet: (filter, globalConditions) ->
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
      , silent: true

  getTargetName: ->
    targetName = @get 'targetName'
    if _.isString(targetName)
      unless targetName is 'body' or targetName.charAt(0) is '.'
        targetName = ".#{targetName}"
    return targetName
