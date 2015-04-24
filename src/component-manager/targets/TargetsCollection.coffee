class TargetsCollection extends Backbone.Collection

  TARGET_PREFIX = 'component-area'
  model: TargetModel

  parse: (response, options) ->
    targets = []

    for targetName, instanceDefinitions of response
      instanceDefinitionsArray = []
      targetName = "#{TARGET_PREFIX}-#{targetName}"

      for instanceDefinition in instanceDefinitions
        instanceDefinition.targetName = targetName
        instanceDefinitionModel = new InstanceDefinitionModel instanceDefinition
        instanceDefinitionsArray.push instanceDefinitionModel

      targets.push
        targetName: targetName
        instanceDefinitionsArray: instanceDefinitionsArray

    return targets
