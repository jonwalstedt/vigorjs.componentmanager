class ComponentDefinitionModel extends Backbone.Model
  defaults:
    componentId: undefined
    src: undefined
    showcount: undefined
    height: undefined
    args: undefined
    conditions: undefined
    instance: undefined

    maxShowCount: 0

  validate: (attrs, options) ->
    unless attrs.componentId
      throw 'componentId cant be undefined'

    unless typeof attrs.componentId is 'string'
      throw 'componentId should be a string'

    unless /^.*[^ ].*$/.test(attrs.componentId)
      throw 'componentId can not be an empty string'

    unless attrs.src
      throw 'src should be a url or classname'

    unless _.isString(attrs.src)
      throw 'src should be a string'

    unless /^.*[^ ].*$/.test(attrs.src)
      throw 'src can not be an empty string'

