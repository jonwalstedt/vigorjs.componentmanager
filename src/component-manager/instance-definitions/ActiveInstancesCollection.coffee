class ActiveInstancesCollection extends BaseInstanceCollection

  getStrays: ->
    _.filter @models, (model) =>
      return not model.isAttached()

