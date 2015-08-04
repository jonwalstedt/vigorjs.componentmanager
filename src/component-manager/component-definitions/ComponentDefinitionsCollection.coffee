class ComponentDefinitionsCollection extends BaseCollection

  model: ComponentDefinitionModel

  ERROR:
    UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'

  getComponentClassByInstanceDefinition: (instanceDefinition) ->
    componentDefinition = @getComponentDefinitionByInstanceDefinition instanceDefinition
    return componentDefinition.getClass()

  getComponentDefinitionByInstanceDefinition: (instanceDefinition) ->
    componentId = instanceDefinition.get 'componentId'
    return @getComponentDefinitionById componentId

  getComponentDefinitionById: (componentId) ->
    componentDefinition = @get componentId
    unless componentDefinition
      throw @ERROR.UNKNOWN_COMPONENT_DEFINITION
    return componentDefinition
