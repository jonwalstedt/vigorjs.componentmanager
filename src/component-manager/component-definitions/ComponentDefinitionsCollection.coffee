class ComponentDefinitionsCollection extends BaseCollection

  model: ComponentDefinitionModel

  ERROR:
    UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'

  getComponentClassPromisesByInstanceDefinitions: (instanceDefinitions) ->
    promises = []
    for instanceDefinition in instanceDefinitions
      componentDefinition = @getComponentDefinitionByInstanceDefinition instanceDefinition
      promises.push componentDefinition.getClass()
    return promises

  getComponentClassPromiseByInstanceDefinition: (instanceDefinition) ->
    componentDefinition = @getComponentDefinitionByInstanceDefinition instanceDefinition
    return componentDefinition.getClass()

  getComponentClassByInstanceDefinition: (instanceDefinition) ->
    componentDefinition = @getComponentDefinitionByInstanceDefinition instanceDefinition
    return componentDefinition.get 'componentClass'

  getComponentDefinitionByInstanceDefinition: (instanceDefinition) ->
    componentId = instanceDefinition.get 'componentId'
    return @getComponentDefinitionById componentId

  getComponentDefinitionById: (componentId) ->
    componentDefinition = @get componentId
    unless componentDefinition
      throw @ERROR.UNKNOWN_COMPONENT_DEFINITION
    return componentDefinition
