do ->

  componentDefinitionsCollection = new ComponentDefinitionsCollection()
  layoutsCollection = new LayoutCollection()
  activeComponents = new Backbone.Collection()

  componentManager =

    initialize: (settings) ->
      if settings.componentSettings
        @_parseComponentSettings settings.componentSettings


    registerComponents: (componentDefinitions) ->
      componentDefinitionsCollection.set componentDefinitions, validate: true, parse: true

    registerLayouts: (layouts) ->
      layoutsCollection.set layouts, validate: true, parse: true
      console.log layoutsCollection

    renderComponents: (filterOptions) ->
      components = @_geComponentInstances filterOptions
      console.log 'componentInstances', components


    # stringToMatchFiltersAgainst: ->
    #   # TODO: pass in a getSourceForFiltersMethod to initialize?
    #   console.log 'stringToMatchFiltersAgainst'

    _geComponentInstances: (filterOptions) ->
      components = layoutsCollection.getComponents filterOptions
      instances = []
      for component in components
        console.log 'component: ', component
        componentDefinition = componentDefinitionsCollection.findWhere componentId: component.get('componentId')
        componentClass = @_getClass componentDefinition.get('src')
        urlParams = router.getArguments component.get('urlPattern'), filterOptions.route
        console.log componentClass, urlParams

      return

    # _setActiveComponents: ->
    #   stringToMatchFiltersAgainst = @stringToMatchFiltersAgainst()
    #   path = @_getPath()
    #   urlParams = @_getUrlParams()

    _getClass: (src) ->
      if typeof require is "function"
        console.log 'require stuff'
        componentClass = require src

      else
        obj = window
        srcObjParts = src.split '.'

        for part in srcObjParts
          obj = obj[part]

        componentClass = obj

      return componentClass

    # _getPath: ->
    #   console.log '_getPath'

    # _getUrlParams: ->
    #  console.log '_getUrlParams'

    _parseComponentSettings: (componentSettings) ->
      componentsDefinitions = componentSettings.components or componentSettings.widgets
      layouts = componentSettings.layouts or componentSettings.targets
      hidden = componentSettings.hidden

      @registerComponents componentsDefinitions
      @registerLayouts layouts


  Vigor.componentManager = componentManager