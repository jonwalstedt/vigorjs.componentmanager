router = new Router()

class InstanceDefinitionsCollection extends Backbone.Collection

  targetPrefix: undefined
  model: InstanceDefinitionModel

  setTargetPrefix: (@targetPrefix) ->

  parse: (response, options) ->
    parsedResponse = undefined
    instanceDefinitionsArray = []

    if _.isObject(response) and not _.isArray(response)
      for targetName, instanceDefinitions of response
        if _.isArray(instanceDefinitions)
          for instanceDefinition in instanceDefinitions

            instanceDefinition.targetName = "#{@targetPrefix}--#{targetName}"
            @parseInstanceDefinition instanceDefinition
            instanceDefinitionsArray.push instanceDefinition

          parsedResponse = instanceDefinitionsArray

        else
          parsedResponse = @parseInstanceDefinition(response)
          break

    else if _.isArray(response)
      for instanceDefinition, i in response
        response[i] = @parseInstanceDefinition(instanceDefinition)
      parsedResponse = response

    return parsedResponse

  parseInstanceDefinition: (instanceDefinition) ->
    instanceDefinition.urlParamsModel = new Backbone.Model()
    if instanceDefinition.urlPattern is 'global'
      instanceDefinition.urlPattern = ['*notFound', '*action']
    return instanceDefinition

  getInstanceDefinitions: (filterOptions) ->
    instanceDefinitions = @models
    if filterOptions.route or filterOptions.route is ''
      instanceDefinitions = @filterInstanceDefinitionsByUrl instanceDefinitions, filterOptions.route
      instanceDefinitions = @addUrlParams instanceDefinitions, filterOptions.route

    if filterOptions.filterString
      instanceDefinitions = @filterInstanceDefinitionsByString instanceDefinitions, filterOptions.filterString

    if filterOptions.conditions
      instanceDefinitions = @filterInstanceDefinitionsByConditions instanceDefinitions, filterOptions.conditions

    return instanceDefinitions

  getInstanceDefinitionsByUrl: (route) ->
    return @filterInstanceDefinitionsByUrl @models, route

  filterInstanceDefinitionsByUrl: (instanceDefinitions, route) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) =>
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

  filterInstanceDefinitionsByString: (instanceDefinitions, filterString) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) ->
      filter = instanceDefinitionModel.get 'filter'
      unless filter
        return false
      else
        return filterString.match new RegExp(filter)

  filterInstanceDefinitionsByConditions: (instanceDefinitions, conditions) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) ->
      instanceConditions = instanceDefinitionModel.get 'conditions'
      shouldBeIncluded = true

      if instanceConditions
        if _.isArray(instanceConditions)
          for condition in instanceConditions

            if _.isFunction(condition) and not condition()
              shouldBeIncluded = false
              return

            else if _.isString(condition)
              shouldBeIncluded = conditions[condition]()

        else if _.isFunction(instanceConditions)
          shouldBeIncluded = instanceConditions()

        else if _.isString(instanceConditions)
          shouldBeIncluded = conditions[instanceConditions]()

      return shouldBeIncluded

  addUrlParams: (instanceDefinitions, route) ->
    for instanceDefinition in instanceDefinitions
      urlParams = router.getArguments instanceDefinition.get('urlPattern'), route
      urlParams.route = route

      urlParamsModel = instanceDefinition.get 'urlParamsModel'
      urlParamsModel.set urlParams

      instanceDefinition.set
        'urlParams': urlParams
      , silent: not instanceDefinition.get('reInstantiateOnUrlParamChange')

    return instanceDefinitions