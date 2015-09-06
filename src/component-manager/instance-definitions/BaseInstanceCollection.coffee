class BaseInstanceCollection extends BaseCollection

  ERROR:
    UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'

  model: InstanceDefinitionModel

  getInstanceDefinition: (instanceId) ->
    instanceDefinition = @get instanceId
    unless instanceDefinition
      throw @ERROR.UNKNOWN_INSTANCE_DEFINITION
    return instanceDefinition
