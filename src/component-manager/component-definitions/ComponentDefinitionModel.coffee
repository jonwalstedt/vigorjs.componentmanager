class ComponentDefinitionModel extends BaseModel

  ERROR:
    VALIDATION:
      ID_UNDEFINED: 'id cant be undefined'
      ID_NOT_A_STRING: 'id should be a string'
      ID_IS_EMPTY_STRING: 'id can not be an empty string'
      SRC_UNDEFINED: 'src cant be undefined'
      SRC_WRONG_TYPE: 'src should be a string or a constructor function'
      SRC_IS_EMPTY_STRING: 'src can not be an empty string'

    NO_CONSTRUCTOR_FOUND: (src) ->
      return "No constructor function found for #{src}"

    MISSING_CONDITION: (condition) ->
      return "Trying to verify condition #{condition} but it has not been registered yet"

  defaults:
    id: undefined
    src: undefined
    componentClass: undefined
    args: undefined
    conditions: undefined
    maxShowCount: undefined
    vcmArgumentFields: undefined
    vcmArgumentFieldValues: undefined

  deferred: undefined

  initialize: ->
    @deferred = $.Deferred()
    super

  validate: (attrs, options) ->
    unless attrs.id
      throw @ERROR.VALIDATION.ID_UNDEFINED

    unless typeof attrs.id is 'string'
      throw @ERROR.VALIDATION.ID_NOT_A_STRING

    if /^\s+$/g.test(attrs.id)
      throw @ERROR.VALIDATION.ID_IS_EMPTY_STRING

    unless attrs.src
      throw @ERROR.VALIDATION.SRC_UNDEFINED

    isValidType = _.isString(attrs.src) or _.isFunction(attrs.src)
    unless isValidType
      throw @ERROR.VALIDATION.SRC_WRONG_TYPE

    if _.isString(attrs.src) and /^\s+$/g.test(attrs.src)
      throw @ERROR.VALIDATION.SRC_IS_EMPTY_STRING

  getClass: ->
    src = @get 'src'
    resolveClassPromise = (componentClass) =>
      if _.isFunction(componentClass)
        @set 'componentClass', componentClass, { silent: true }
        @deferred.resolve {componentDefinition: @, componentClass: componentClass}
      else
        throw @ERROR.NO_CONSTRUCTOR_FOUND src

    if @get('componentClass')
      resolveClassPromise @get('componentClass')
    else
      if _.isString(src) and @_isUrl(src)
        resolveClassPromise Vigor.IframeComponent

      else if _.isString(src)
        # AMD require asynchronous
        if (_.isString(src) and typeof define is "function" and define.amd)
          Vigor.require [src], (componentClass) =>
            resolveClassPromise componentClass

        # CommonJS require - synchronus
        else if (_.isString(src) and typeof exports is "object")
          resolveClassPromise Vigor.require src

        # try to find class through namespace path from the window object
        else
          obj = window
          srcObjParts = src.split '.'

          for part in srcObjParts
            obj = obj[part]

          resolveClassPromise obj

      # if the class is set directly on the src attribute
      else if _.isFunction(src)
        resolveClassPromise src
      else
        throw @ERROR.VALIDATION.SRC_WRONG_TYPE

    return @deferred.promise()

  getComponentClassPromise: ->
    return @deferred.promise()

  passesFilter: (filterModel, globalConditionsModel) ->
    unless @_areConditionsMet filterModel, globalConditionsModel
      return false
    return true

  _areConditionsMet: (filterModel, globalConditionsModel) ->
    filter = filterModel?.toJSON() or {}
    globalConditions = globalConditionsModel?.toJSON() or {}
    componentConditions = @get 'conditions'
    shouldBeIncluded = true

    if componentConditions
      unless _.isArray(componentConditions)
        componentConditions = [componentConditions]

      for condition in componentConditions
        if _.isFunction(condition) and not condition(filter, @getArgs())
          shouldBeIncluded = false
          break

        else if _.isString(condition)
          unless globalConditions[condition]?
            throw @ERROR.MISSING_CONDITION condition

          shouldBeIncluded = !!globalConditions[condition](filter, @getArgs())
          if not shouldBeIncluded
            break

    return shouldBeIncluded

  _isUrl: (string) ->
    urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    return urlRegEx.test(string)
