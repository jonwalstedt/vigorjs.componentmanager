class ActiveComponentsCollection extends Backbone.Collection

  model: ComponentDefinitionModel

  getStrays: ->
    strays = _.filter @models, (model) =>
      if instance = model.get('instance')
        return not @isAttached(instance)
      else false
    return strays

  isAttached: (instance) ->
    elem = instance.el
    return $.contains document.body, elem
