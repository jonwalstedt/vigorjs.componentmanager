do ->

  COMPONENT_CLASS = 'vigorjs-component'

  componentDefinitionsCollection = new ComponentDefinitionsCollection()
  instanceDefinitionsCollection = new InstanceDefinitionsCollection()
  activeComponents = new Backbone.Collection()
  filterModel = new FilterModel()

  componentManager =

    initialize: (settings) ->
      if settings.componentSettings
        _parseComponentSettings settings.componentSettings

      filterModel.on 'change', _updateActiveComponents
      componentDefinitionsCollection.on 'change', _updateActiveComponents
      instanceDefinitionsCollection.on 'change', _updateActiveComponents

      activeComponents.on 'add', _onComponentAdded
      activeComponents.on 'remove', _onComponentRemoved
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

    dispose: ->
      do @clear
      do filterModel.off
      do activeComponents.off
      do componentDefinitionsCollection.off
      filterModel = undefined
      activeComponents = undefined
      componentDefinitionsCollection = undefined

    getComponentInstances: (filterOptions) ->
      return _getComponentInstances filterOptions

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
    componentInstances = _getComponentInstances filterOptions
    activeComponents.set componentInstances

  _getComponentInstances = (filterOptions) ->
    instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinition filterOptions
    instances = []
    for instanceDefinition in instanceDefinitions
      filter = instanceDefinition.get 'filter'
      componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
      showCount = instanceDefinition.get 'showCount'
      maxShowCount = componentDefinition.get 'maxShowCount'
      isFilteredOut = false

      componentClass = _getClass componentDefinition.get('src')
      urlParams = router.getArguments instanceDefinition.get('urlPattern'), filterOptions.route

      instance = new componentClass { urlParams: urlParams, args: instanceDefinition.get('args') }
      instance.$el.addClass COMPONENT_CLASS

      obj = {
        instance: instance
        instanceDefinitionId: instanceDefinition.get('id') or instanceDefinition.cid
        target: instanceDefinition.get('targetName')
        order: instanceDefinition.get('order')
      }

      if filter and filterOptions.filterString
        isFilteredOut = not filterOptions.filterString.match (new RegExp(filter))
      else
        isFilteredOut = false

      unless isFilteredOut
        if maxShowCount
          if showCount < maxShowCount
            instanceDefinition.set 'showCount', showCount++
            instances.push obj
        else
          instanceDefinition.set 'showCount', showCount++
          instances.push obj

    return instances

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
    componentDefinitionsCollection.set componentDefinitions, validate: true, parse: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    instanceDefinitionsCollection.set instanceDefinitions, validate: true, parse: true

  _addInstanceToDom = (model, render = true) ->
    $target = $ ".#{model.get('target')}"
    order = model.get 'order'
    instance = model.get 'instance'

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

  #
  # Callbacks
  # ============================================================================
  _onComponentAdded = (model) ->
    _addInstanceToDom model

  _onComponentRemoved = (model) ->
    instance = model.get 'instance'
    do instance.dispose

  Vigor.componentManager = componentManager