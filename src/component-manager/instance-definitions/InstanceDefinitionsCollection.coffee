class InstanceDefinitionsCollection extends BaseInstanceCollection

  parse: (data, options) ->
    parsedResponse = undefined
    instanceDefinitionsArray = []

    targetPrefix = data.targetPrefix
    incomingInstanceDefinitions = data.instanceDefinitions

    if _.isObject(incomingInstanceDefinitions) and not _.isArray(incomingInstanceDefinitions)
      for targetName, instanceDefinitions of incomingInstanceDefinitions
        if _.isArray(instanceDefinitions)
          for instanceDefinition in instanceDefinitions
            instanceDefinition.targetName = "#{targetPrefix}--#{targetName}"
            @parseInstanceDefinition instanceDefinition
            instanceDefinitionsArray.push instanceDefinition

          parsedResponse = instanceDefinitionsArray

        else
          trgtName = incomingInstanceDefinitions.targetName
          if trgtName? and trgtName isnt 'body' and trgtName.indexOf(targetPrefix) < 0
            incomingInstanceDefinitions.targetName = "#{targetPrefix}--#{trgtName}"
          parsedResponse = @parseInstanceDefinition(incomingInstanceDefinitions)
          break

    else if _.isArray(incomingInstanceDefinitions)
      for instanceDefinition, i in incomingInstanceDefinitions
        targetName = instanceDefinition.targetName
        if targetName? and targetName isnt 'body' and targetName.indexOf(targetPrefix) < 0
          instanceDefinition.targetName = "#{targetPrefix}--#{targetName}"
        incomingInstanceDefinitions[i] = @parseInstanceDefinition(instanceDefinition)
      parsedResponse = incomingInstanceDefinitions

    return parsedResponse

  parseInstanceDefinition: (instanceDefinition) ->
    instanceDefinition.urlParamsModel = new Backbone.Model()
    if instanceDefinition.urlPattern is 'global'
      instanceDefinition.urlPattern = ['*notFound', '*action']
    return instanceDefinition

  filterInstanceDefinitions: (filterModel, globalConditions) ->
    filter = filterModel?.toJSON() or {}
    instanceDefinitions = @models
    if filterModel
      blackListedKeys = _.keys filterModel.defaults
      customFilter = _.omit filter, blackListedKeys

      for key, val of customFilter
        if customFilter.hasOwnProperty(key) and customFilter[key] is undefined
          delete customFilter[key]

      unless _.isEmpty(customFilter)
        instanceDefinitions = @where customFilter

    instanceDefinitions = _.filter instanceDefinitions, (instanceDefinitionModel) ->
      instanceDefinitionModel.passesFilter filter, globalConditions

    return instanceDefinitions

  addUrlParams: (instanceDefinitions, url) ->
    for instanceDefinitionModel in instanceDefinitions
      instanceDefinitionModel.addUrlParams url
    return instanceDefinitions