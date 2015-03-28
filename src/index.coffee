do ->

  componentDefinitionsCollection = new ComponentDefinitionsCollection()
  targetsCollection = new TargetsCollection()

  componentManager =

    initialize: (settings) ->
      if settings.componentSettings
        @parseComponentSettings settings.componentSettings

    parseComponentSettings: (componentSettings) ->
      componentsDefinitions = componentSettings.components or componentSettings.widgets
      targets = componentSettings.targets
      hidden = componentSettings.hidden

      @registerComponents componentsDefinitions
      @registerTargets targets

    registerComponents: (componentDefinitions) ->
      componentDefinitionsCollection.set componentDefinitions, validate: true, parse: true

    registerTargets: (targets) ->
      targetsCollection.set targets, validate: true, parse: true

  Vigor.componentManager = componentManager