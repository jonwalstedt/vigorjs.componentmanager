class InstanceDefinitionModel extends Backbone.Model

  defaults:
    id: undefined
    componentId: undefined
    filter: undefined
    urlPattern: undefined
    args: undefined
    order: undefined
    targetName: undefined
    instance: undefined
    showCount: 0
    urlParams: undefined
    reRenderOnUrlParamChange: false

  dispose: ->
    instance = @get 'instance'
    if instance
      do instance.dispose
      do @clear

  # validate: (attrs, options) ->
  #   console.log 'TargetsCollection:validate', attrs