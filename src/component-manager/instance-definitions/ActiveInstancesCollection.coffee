class ActiveInstancesCollection extends BaseInstanceCollection

  model: InstanceDefinitionModel

  getStrays: ->
    _.filter @models, (model) =>
      return not model.isAttached()

