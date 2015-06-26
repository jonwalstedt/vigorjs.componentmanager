class InstanceDefinitionsCollection extends BaseCollection

  _targetPrefix = undefined
  model: InstanceDefinitionModel

  setTargetPrefix: (targetPrefix) ->
    _targetPrefix = targetPrefix

  getTargetPrefix: ->
    return _targetPrefix

  parse: (data, options) ->
    parsedResponse = undefined
    instanceDefinitionsArray = []

    if _.isObject(data) and not _.isArray(data)
      for targetName, instanceDefinitions of data
        if _.isArray(instanceDefinitions)
          for instanceDefinition in instanceDefinitions

            instanceDefinition.targetName = "#{_targetPrefix}--#{targetName}"
            @parseInstanceDefinition instanceDefinition
            instanceDefinitionsArray.push instanceDefinition

          parsedResponse = instanceDefinitionsArray

        else
          parsedResponse = @parseInstanceDefinition(data)
          break

    else if _.isArray(data)
      for instanceDefinition, i in data
        data[i] = @parseInstanceDefinition(instanceDefinition)
      parsedResponse = data

    return parsedResponse

  parseInstanceDefinition: (instanceDefinition) ->
    instanceDefinition.urlParamsModel = new Backbone.Model()
    if instanceDefinition.urlPattern is 'global'
      instanceDefinition.urlPattern = ['*notFound', '*action']
    return instanceDefinition

  getInstanceDefinitions: (filter, globalConditions) ->
    return @filter (instanceDefinitionModel) ->
      instanceDefinitionModel.passesFilter filter, globalConditions

  addUrlParams: (instanceDefinitions, url) ->
    for instanceDefinitionModel in instanceDefinitions
      instanceDefinitionModel.addUrlParams url
    return instanceDefinitions