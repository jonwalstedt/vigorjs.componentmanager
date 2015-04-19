class ActiveComponentsCollection extends Backbone.Collection

  model: ComponentDefinitionModel

  getStrays: ->
    strays = _.filter @models, (model) =>
      if model.get('instance')
        return not model.isAttached()
      else false
    return strays

