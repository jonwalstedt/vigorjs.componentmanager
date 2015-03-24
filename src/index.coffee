do ->

  componentDefinitionsCollection = new ComponentDefinitionsCollection()

  componentManager =
    registerComponents: (componentDefinitions) ->
      for componentDefinition in componentDefinitions
        @registerComponent componentDefinition

    registerComponent: (componentDefinition) ->
      componentDefinitionsCollection.add componentDefinition

    renderComponents: ->



  Vigor.componentManager = componentManager