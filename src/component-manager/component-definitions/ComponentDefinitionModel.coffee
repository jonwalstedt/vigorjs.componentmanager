class ComponentDefinitionModel extends Backbone.Model
  defaults:
    id: undefined
    src: undefined
    height: undefined
    args: undefined
    conditions: undefined
    instance: undefined
    maxShowCount: undefined

  validate: (attrs, options) ->
    unless attrs.id
      throw 'id cant be undefined'

    unless typeof attrs.id is 'string'
      throw 'id should be a string'

    if /^\s+$/g.test(attrs.id)
      throw 'id can not be an empty string'

    unless attrs.src
      throw 'src cant be undefined'

    isValidType = _.isString(attrs.src) or _.isFunction(attrs.src)
    unless isValidType
      throw 'src should be a string or a constructor function'

    if _.isString(attrs.src) and /^\s+$/g.test(attrs.src)
      throw 'src can not be an empty string'


  getClass: ->
    src = @get 'src'
    if _.isString(src) and @_isUrl(src)
      componentClass = Vigor.IframeComponent

    else if _.isString(src)
      obj = window
      srcObjParts = src.split '.'

      for part in srcObjParts
        obj = obj[part]

      componentClass = obj

    else if _.isFunction(src)
      componentClass = src

    unless _.isFunction(componentClass)
      throw "No constructor function found for #{src}"

    return componentClass

  areConditionsMet: (globalConditions) ->
    componentConditions = @get 'conditions'
    shouldBeIncluded = true

    if componentConditions
      unless _.isArray(componentConditions)
        componentConditions = [componentConditions]

      for condition in componentConditions
        if _.isFunction(condition) and not condition()
          shouldBeIncluded = false
          break

        else if _.isString(condition)
          unless globalConditions
            throw 'No global conditions was passed, condition could not be tested'

          unless globalConditions[condition]?
            throw "Trying to verify condition #{condition} but it has not been registered yet"

          shouldBeIncluded = !!globalConditions[condition]()
          if not shouldBeIncluded
            break

    return shouldBeIncluded

  _isUrl: (string) ->
    urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    return urlRegEx.test(string)
