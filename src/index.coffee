do ->

  COMPONENT_CLASS = 'vigorjs-component'

  componentDefinitionsCollection = new ComponentDefinitionsCollection()
  instanceDefinitionsCollection = new InstanceDefinitionsCollection()
  activeComponents = new Backbone.Collection()
  filterModel = new FilterModel()

  componentManager =
    activeComponents: activeComponents

    initialize: (settings) ->
      if settings.componentSettings
        _parseComponentSettings settings.componentSettings

      filterModel.on 'add change remove', _updateActiveComponents
      componentDefinitionsCollection.on 'add change remove', _updateActiveComponents
      instanceDefinitionsCollection.on 'add change remove', _updateActiveComponents

      @activeComponents.on 'add', _onComponentAdded
      @activeComponents.on 'remove', _onComponentRemoved
      return @

    refresh: (filterOptions) ->
      filterModel.set filterOptions
      return @

    addComponentDefinition: (componentDefinition) ->
      componentDefinitionsCollection.set componentDefinition,
        validate: true,
        parse: true,
        remove: false
      return @

    removeComponentDefinition: (componentDefinitionId) ->
      instanceDefinitionsCollection.remove componentDefinitionId
      return @

    addInstance: (instanceDefinition) ->
      instanceDefinitionsCollection.set instanceDefinition,
        validate: true,
        parse: true,
        remove: false
      return @

    removeInstance: (instancecId) ->
      instanceDefinitionsCollection.remove instancecId
      return @

    clear: ->
      do componentDefinitionsCollection.reset
      do instanceDefinitionsCollection.reset
      do activeComponents.reset
      do filterModel.clear
      return @

    dispose: ->
      do @clear
      do filterModel.off
      do activeComponents.off
      do componentDefinitionsCollection.off
      filterModel = undefined
      activeComponents = undefined
      componentDefinitionsCollection = undefined

    getComponentInstances: (filterOptions) ->
      instanceDefinitions = _filterInstanceDefinitions filterOptions
      instances = []
      for instanceDefinition in instanceDefinitions
        instance = instanceDefinition.get 'instance'
        unless instance
          _addInstanceToModel instanceDefinition
          instance = instanceDefinition.get 'instance'
        instances.push instance
      return instances

  #
  # Privat methods
  # ============================================================================
  _previousElement = ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        _previousElement $el.prev(), order

  _updateActiveComponents = ->
    filterOptions = filterModel.toJSON()
    instanceDefinitions = _filterInstanceDefinitions filterOptions
    activeComponents.set instanceDefinitions

  _filterInstanceDefinitions = (filterOptions) ->
    instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions filterOptions
    filteredInstanceDefinitions = []

    for instanceDefinition in instanceDefinitions
      componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
      showCount = instanceDefinition.get 'showCount'

      # maxShowCount on an instance level overrides maxShowCount on a componentDefinition level
      maxShowCount = instanceDefinition.get 'maxShowCount'
      unless maxShowCount
        maxShowCount = componentDefinition.get 'maxShowCount'

      if maxShowCount
        if showCount < maxShowCount
          _incrementShowCount instanceDefinition
          filteredInstanceDefinitions.push instanceDefinition

      else
        filteredInstanceDefinitions.push instanceDefinition
        _incrementShowCount instanceDefinition

    return filteredInstanceDefinitions

  _getClass = (src) ->
    if typeof require is "function"
      console.log 'require stuff'
      componentClass = require src

    else
      obj = window
      srcObjParts = src.split '.'

      for part in srcObjParts
        obj = obj[part]

      componentClass = obj

    unless typeof componentClass is "function"
      throw "No constructor function found for #{src}"

    return componentClass

  _parseComponentSettings = (componentSettings) ->
    componentDefinitions = componentSettings.components or \
    componentSettings.widgets or \
    componentSettings.componentDefinitions

    instanceDefinitions = componentSettings.layoutsArray or \
    componentSettings.targets or \
    componentSettings.instanceDefinitions

    hidden = componentSettings.hidden

    _registerComponents componentDefinitions
    _registerInstanceDefinitons instanceDefinitions

  _registerComponents = (componentDefinitions) ->
    componentDefinitionsCollection.set componentDefinitions,
      validate: true
      parse: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    instanceDefinitionsCollection.set instanceDefinitions,
      validate: true
      parse: true

  _addInstanceToDom = (instanceDefinition, render = true) ->
    $target = $ ".#{instanceDefinition.get('targetName')}"
    order = instanceDefinition.get 'order'
    instance = instanceDefinition.get 'instance'

    if render then do instance.render

    if order
      if order is 'top'
        instance.$el.data 'order', 0
        $target.prepend instance.$el
      else if order is 'bottom'
        instance.$el.data 'order', 999
        $target.append instance.$el
      else
        $previousElement = _previousElement $target.children().last(), order
        instance.$el.data 'order', order
        instance.$el.attr 'data-order', order
        unless $previousElement
          $target.prepend instance.$el
        else
          instance.$el.insertAfter $previousElement
    else
      $target.append instance.$el

  _addInstanceToModel = (instanceDefinition) ->
    componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
    componentClass = _getClass componentDefinition.get('src')

    args =
      urlParams: instanceDefinition.get 'urlParams'

    _.extend args, instanceDefinition.get('args')

    instance = new componentClass args
    instance.$el.addClass COMPONENT_CLASS

    instanceDefinition.set
      'instance': instance
    , silent: true

    return instanceDefinition

  _incrementShowCount = (instanceDefinition, silent = true) ->
    showCount = instanceDefinition.get 'showCount'
    instanceDefinition.set
      'showCount': showCount += 1
    , silent: silent

  #
  # Callbacks
  # ============================================================================
  _onComponentAdded = (instanceDefinition) ->
    _addInstanceToModel instanceDefinition
    _addInstanceToDom instanceDefinition

  _onComponentRemoved = (instanceDefinition) ->
    instance = instanceDefinition.get 'instance'
    do instance.dispose

  Vigor.componentManager = componentManager
