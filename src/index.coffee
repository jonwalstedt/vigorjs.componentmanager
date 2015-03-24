do ->

  componentDefinitionsCollection = new ComponentDefinitionsCollection()

  componentManager =

    registerComponents: (componentDefinitions) ->
      componentDefinitionsCollection.set componentDefinitions

    renderComponents: ->



  Vigor.componentManager = componentManager