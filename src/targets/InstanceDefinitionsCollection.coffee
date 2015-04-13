router = new Router()

class InstanceDefinitionsCollection extends Backbone.Collection

  TARGET_PREFIX = 'component-area'
  model: InstanceDefinitionModel

  parse: (response, options) ->
    instanceDefinitionsArray = []
    for targetName, instanceDefinitions of response
      for instanceDefinition in instanceDefinitions

        instanceDefinition.targetName = "#{TARGET_PREFIX}-#{targetName}"

        if instanceDefinition.urlPattern is 'global'
          instanceDefinition.urlPattern = ['*notFound', '*action']

        instanceDefinitionsArray.push instanceDefinition

    return instanceDefinitionsArray

  getInstanceDefinitions: (filterOptions) ->
    instanceDefinitions = @models
    if filterOptions.route or filterOptions.route is ''
      instanceDefinitions = @filterInstanceDefinitionsByUrl instanceDefinitions, filterOptions.route
      instanceDefinitions = @addUrlParams instanceDefinitions, filterOptions.route

    if filterOptions.filterString
      instanceDefinitions = @filterInstanceDefinitionsByString instanceDefinitions, filterOptions.filterString

    return instanceDefinitions

  getInstanceDefinitionsByUrl: (route) ->
    return @filterInstanceDefinitionsByUrl @models, route

  filterInstanceDefinitionsByUrl: (instanceDefinitions, route) ->
    instanceDefinitions = _.filter instanceDefinitions, (instanceDefinitionModel) =>
      urlPattern = instanceDefinitionModel.get 'urlPattern'
      if urlPattern
        if _.isArray(urlPattern)
          match = false
          for pattern in urlPattern
            routeRegEx = router._routeToRegExp pattern
            match = routeRegEx.test route
            if match then return match
          return match
        else
          routeRegEx = router._routeToRegExp urlPattern
          return routeRegEx.test route
    return instanceDefinitions

  filterInstanceDefinitionsByString: (instanceDefinitions, filterString) ->
    instanceDefinitions = _.filter instanceDefinitions, (instanceDefinitionModel) ->
      filter = instanceDefinitionModel.get 'filter'
      unless filter
        return false
      else
        return filterString.match new RegExp(filter)
    return instanceDefinitions

  addUrlParams: (instanceDefinitions, route) ->
    for instanceDefinition in instanceDefinitions
      urlParams = router.getArguments instanceDefinition.get('urlPattern'), route
      instanceDefinition.set
        'urlParams': urlParams
      , silent: true
    return instanceDefinitions

