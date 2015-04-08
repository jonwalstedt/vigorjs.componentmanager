router = new Router()

class InstanceDefinitionsCollection extends Backbone.Collection

  TARGET_PREFIX = 'component-area'
  model: InstanceDefinitionModel

  parse: (response, options) ->
    instanceDefinitionsArray = []
    for targetName, instanceDefinitions of response
      for instanceDefinition in instanceDefinitions
        instanceDefinition.targetName = "#{TARGET_PREFIX}-#{targetName}"
        instanceDefinitionsArray.push instanceDefinition

    return instanceDefinitionsArray

  getInstanceDefinition: (filterOptions) ->
    instanceDefinitions = @models
    if filterOptions.route
      instanceDefinitions = @filterInstanceDefinitionsByUrl instanceDefinitions, filterOptions.route

    return instanceDefinitions

  getInstanceDefinitionsByUrl: (route) ->
    return @filterInstanceDefinitionsByUrl @models, route

  filterInstanceDefinitionsByUrl: (instanceDefinitions, route) ->
    instanceDefinitions = _.filter instanceDefinitions, (instanceDefinitionModel) =>
      urlPattern = instanceDefinitionModel.get 'urlPattern'
      if urlPattern
        routeRegEx = router._routeToRegExp urlPattern
        return routeRegEx.test route
    return instanceDefinitions


