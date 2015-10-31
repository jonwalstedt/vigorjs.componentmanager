class ComponentDefinitionModel extends Backbone.Model

  ERROR:
    VALIDATION:
      ID_UNDEFINED: 'id cant be undefined'
      ID_NOT_A_STRING: 'id should be a string'
      ID_IS_EMPTY_STRING: 'id can not be an empty string'
      SRC_UNDEFINED: 'src cant be undefined'
      SRC_WRONG_TYPE: 'src should be a string or a constructor function'
      SRC_IS_EMPTY_STRING: 'src can not be an empty string'

    MISSING_GLOBAL_CONDITIONS: 'No global conditions was passed, condition could not be tested'

    NO_CONSTRUCTOR_FOUND: (src) ->
      return "No constructor function found for #{src}"

    MISSING_CONDITION: (condition) ->
      return "Trying to verify condition #{condition} but it has not been registered yet"

  defaults:
    id: undefined
    src: undefined
    args: undefined
    conditions: undefined
    maxShowCount: undefined

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
    if _.isString(src) and @_isUrl(src)
      componentClass = Vigor.IframeComponent

    else if _.isString(src)
      # AMD and CommonJS
      if (_.isString(src) and typeof define is "function" and define.amd) \
      or (_.isString(src) and typeof exports is "object")
        componentClass = require src

      # try to find class through namespace path from the window object
      else
        obj = window
        srcObjParts = src.split '.'

        for part in srcObjParts
          obj = obj[part]

        componentClass = obj

    else if _.isFunction(src)
      componentClass = src

    unless _.isFunction(componentClass)
      throw @ERROR.NO_CONSTRUCTOR_FOUND src

    return componentClass

  areConditionsMet: (filter, globalConditions) ->
    componentConditions = @get 'conditions'
    shouldBeIncluded = true

    if componentConditions
      unless _.isArray(componentConditions)
        componentConditions = [componentConditions]

      for condition in componentConditions
        if _.isFunction(condition) and not condition(filter, @get('args'))
          shouldBeIncluded = false
          break

        else if _.isString(condition)
          unless globalConditions
            throw @ERROR.MISSING_GLOBAL_CONDITIONS

          unless globalConditions[condition]?
            throw @ERROR.MISSING_CONDITION condition

          shouldBeIncluded = !!globalConditions[condition](filter, @get('args'))
          if not shouldBeIncluded
            break

    return shouldBeIncluded

  _isUrl: (string) ->
    urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    return urlRegEx.test(string)
