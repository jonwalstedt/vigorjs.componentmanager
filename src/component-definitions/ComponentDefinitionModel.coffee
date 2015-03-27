class ComponentDefinitionModel extends Backbone.Model
  defaults:
    componentId: undefined
    src: undefined
    height: undefined
    args: undefined
    showcount: undefined
    conditions: undefined

  validate: (attrs, options) ->
    unless attrs.componentId
      throw 'componentId cant be undefined'

    unless typeof attrs.componentId is 'string'
      throw 'componentId should be a string'

    unless /^.*[^ ].*$/.test(attrs.componentId)
      throw 'componentId can not be an empty string'

    unless attrs.src
      throw 'src should be a url or classname'