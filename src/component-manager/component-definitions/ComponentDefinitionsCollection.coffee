class ComponentDefinitionsCollection extends BaseCollection

  model: ComponentDefinitionModel

  ERROR =
    UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'

  getComponentDefinition: (componentId) ->
    componentDefinition = @get componentId
    unless componentDefinition
      throw ERROR.UNKNOWN_COMPONENT_DEFINITION
    return componentDefinition

