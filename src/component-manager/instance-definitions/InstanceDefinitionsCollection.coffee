class InstanceDefinitionsCollection extends BaseInstanceCollection

  model: InstanceDefinitionModel

  parse: (data, options) ->
    parsedResponse = undefined
    instanceDefinitionsArray = []

    targetPrefix = data.targetPrefix
    incomingInstanceDefinitions = data.instanceDefinitions

    if _.isObject(incomingInstanceDefinitions) and not _.isArray(incomingInstanceDefinitions)
      for targetName, instanceDefinitions of incomingInstanceDefinitions
        if _.isArray(instanceDefinitions)
          for instanceDefinition in instanceDefinitions
            instanceDefinition.targetName = @_formatTargetName targetName, targetPrefix
            @parseInstanceDefinition instanceDefinition
            instanceDefinitionsArray.push instanceDefinition

          parsedResponse = instanceDefinitionsArray

        else
          if incomingInstanceDefinitions.targetName
            incomingInstanceDefinitions.targetName = @_formatTargetName incomingInstanceDefinitions.targetName, targetPrefix
          parsedResponse = @parseInstanceDefinition(incomingInstanceDefinitions)
          break

    else if _.isArray(incomingInstanceDefinitions)
      for instanceDefinition, i in incomingInstanceDefinitions
        if instanceDefinition.targetName
          instanceDefinition.targetName = @_formatTargetName instanceDefinition.targetName, targetPrefix
        incomingInstanceDefinitions[i] = @parseInstanceDefinition(instanceDefinition)
      parsedResponse = incomingInstanceDefinitions

    return parsedResponse

  parseInstanceDefinition: (instanceDefinition) ->
    if instanceDefinition.urlPattern is 'global'
      instanceDefinition.urlPattern = ['*notFound', '*action']
    return instanceDefinition

  _formatTargetName: (targetName, targetPrefix) ->
    if _.isString(targetName)
      if targetName isnt 'body'
        if targetName.charAt(0) is '.'
          targetName = targetName.substring 1

        if targetName.indexOf(targetPrefix) < 0
          targetName = "#{targetPrefix}--#{targetName}"

        targetName = ".#{targetName}"
    return targetName
