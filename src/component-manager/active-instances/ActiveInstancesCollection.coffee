class ActiveInstancesCollection extends Backbone.Collection

  model: InstanceDefinitionModel

  getStrays: ->
    strays = _.filter @models, (model) =>
      if model.get('instance')
        return not model.isAttached()
      else false
    return strays

