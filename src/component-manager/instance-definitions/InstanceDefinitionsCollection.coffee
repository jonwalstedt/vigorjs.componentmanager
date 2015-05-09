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

  getInstanceDefinitions: (filter) ->
    return @filter (instanceDefinitionModel) ->
      instanceDefinitionModel.passesFilter filter

  getInstanceDefinitionsByUrl: (route) ->
    return @filterInstanceDefinitionsByUrl @models, route

  filterInstanceDefinitionsByUrl: (instanceDefinitions, route) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) =>
      return instanceDefinitionModel.doesUrlPatternMatch(route)

  filterInstanceDefinitionsByString: (instanceDefinitions, filterString) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) ->
      return instanceDefinitionModel.doesFilterStringMatch filterString

  filterInstanceDefinitionsByConditions: (instanceDefinitions, conditions) ->
    _.filter instanceDefinitions, (instanceDefinitionModel) ->
      return instanceDefinitionModel.areConditionsMet conditions

  addUrlParams: (instanceDefinitions, route) ->
    for instanceDefinitionModel in instanceDefinitions
      instanceDefinitionModel.addUrlParams route
    return instanceDefinitions