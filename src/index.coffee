do ->

  componentDefinitionsCollection = new ComponentDefinitionsCollection()
  targetsCollection = new TargetsCollection()

  componentManager =

    parseComponentSettings: (componentSettings) ->
      componentsDefinitions = componentSettings.components or componentSettings.widgets
      targets = componentSettings.targets
      hidden = componentSettings.hidden

      @registerComponents componentsDefinitions
      @registerTargets targets

    registerComponents: (componentDefinitions) ->
      componentDefinitionsCollection.set componentDefinitions, validate: true

    registerTargets: (targets) ->
      targetsCollection.set targets, validate: true



  Vigor.componentManager = componentManager