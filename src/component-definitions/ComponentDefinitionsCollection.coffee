class ComponentDefinitionsCollection extends Backbone.Collection

  model: ComponentDefinitionModel

  getByComponentId: (componentId) ->
    componentDefinition = @findWhere componentId: componentId
    unless componentDefinition
      throw "Unknown componentId: #{componentId}"
    return componentDefinition

