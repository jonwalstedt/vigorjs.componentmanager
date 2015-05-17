class ActiveInstancesCollection extends BaseCollection

  model: InstanceDefinitionModel

  getStrays: ->
    _.filter @models, (model) =>
      return not model.isAttached()

