class InstanceDefinitionModel extends Backbone.Model

  defaults:
    componentId: undefined
    filter: undefined
    urlPattern: undefined
    args: undefined
    order: undefined
    targetName: undefined
    showCount: 0

  # validate: (attrs, options) ->
  #   console.log 'TargetsCollection:validate', attrs