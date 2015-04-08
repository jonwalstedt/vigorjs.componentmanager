do ->

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

    update: (filterOptions) ->
      filterModel.set filterOptions
      return @

  _onComponentAdded = (model) ->
    $target = $ ".#{model.get('target')}"
    order = model.get 'order'
    instance = model.get 'instance'
    do instance.render

    if order
      if order is 'top'
        $target.prepend instance.$el
      else if order is 'bottom'
        $target.append instance.$el
      else
        # debugger
        # console.log $target
        # if $target.children().length
        #   $target = $target.children().filter(":lt(#{order})").last()
        #   instance.$el.insertAfter $target
        # else
        $target.append instance.$el
    else
      $target.append instance.$el


  _onComponentRemoved = (model) ->
    instance = model.get 'instance'
    do instance.dispose

  _updateActiveComponents = ->
    filterOptions = filterModel.toJSON()
    componentInstances = _geComponentInstances filterOptions
    activeComponents.set componentInstances

  _geComponentInstances = (filterOptions) ->
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

      obj = {
        instanceDefinitionId: instanceDefinition.cid
        instance: instance
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
    componentsDefinitions = componentSettings.components or componentSettings.widgets
    instanceDefinitions = componentSettings.layouts or componentSettings.targets
    hidden = componentSettings.hidden

    _registerComponents componentsDefinitions
    _registerInstanceDefinitons instanceDefinitions

  _registerComponents = (componentDefinitions) ->
    componentDefinitionsCollection.set componentDefinitions, validate: true, parse: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    instanceDefinitionsCollection.set instanceDefinitions, validate: true, parse: true
    console.log instanceDefinitionsCollection

  Vigor.componentManager = componentManager