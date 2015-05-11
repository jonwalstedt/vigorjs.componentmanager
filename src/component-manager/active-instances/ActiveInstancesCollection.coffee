class ActiveInstancesCollection extends Backbone.Collection

  model: InstanceDefinitionModel

  getStrays: ->
    _.filter @models, (model) =>
      return not model.isAttached()

