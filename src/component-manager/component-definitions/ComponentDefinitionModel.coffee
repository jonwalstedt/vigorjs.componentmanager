class ComponentDefinitionModel extends Backbone.Model
  defaults:
    id: undefined
    src: undefined
    showcount: undefined
    height: undefined
    args: undefined
    conditions: undefined
    instance: undefined
    maxShowCount: 0

  validate: (attrs, options) ->
    unless attrs.id
      throw 'id cant be undefined'

    unless typeof attrs.id is 'string'
      throw 'id should be a string'

    unless /^.*[^ ].*$/.test(attrs.id)
      throw 'id can not be an empty string'

    unless attrs.src
      throw 'src should be a url or classname'

    unless _.isString(attrs.src)
      throw 'src should be a string'

    unless /^.*[^ ].*$/.test(attrs.src)
      throw 'src can not be an empty string'

