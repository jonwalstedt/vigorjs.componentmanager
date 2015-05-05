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

  isAttached: ->
    instance = @get 'instance'
    elem = instance.el
    return $.contains document.body, elem

  dispose: ->
    instance = @get 'instance'
    if instance
      do instance.dispose
      do @clear

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
