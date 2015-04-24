do ->

  componentClassName = 'vigor-component'

  componentDefinitionsCollection = undefined
  instanceDefinitionsCollection = undefined
  activeComponents = undefined
  filterModel = undefined
  $context = undefined
  conditions = {}

  componentManager =

    #
    # Public properties
    # ============================================================================
    componentDefinitionsCollection: undefined
    instanceDefinitionsCollection: undefined
    activeComponents: undefined

    #
    # Public methods
    # ============================================================================
    initialize: (settings) ->
      componentDefinitionsCollection = new ComponentDefinitionsCollection()
      instanceDefinitionsCollection = new InstanceDefinitionsCollection()
      activeComponents = new ActiveComponentsCollection()
      filterModel = new FilterModel()

      @activeComponents = activeComponents
      @componentDefinitionsCollection = componentDefinitionsCollection
      @instanceDefinitionsCollection = instanceDefinitionsCollection
      @conditions = conditions

      do _addListeners

      if settings.$context
        $context = settings.$context
      else
        $context = $ 'body'

      if settings.componentSettings
        _parseComponentSettings settings.componentSettings

      if settings.componentSettings.conditions
        @registerConditions settings.componentSettings.conditions

      return @

    registerConditions: (conditionsToBeRegistered) ->
      _.extend conditions, conditionsToBeRegistered

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

    updateInstance: (instanceId, attributes) ->
      instanceDefinition = instanceDefinitionsCollection.get instanceId
      instanceDefinition?.set attributes
      return @

    removeInstance: (instancecId) ->
      instanceDefinitionsCollection.remove instancecId
      return @

    clear: ->
      do componentDefinitionsCollection.reset
      do instanceDefinitionsCollection.reset
      do activeComponents.reset
      do filterModel.clear
      do restrictions = {}
      return @

    dispose: ->
      do @clear
      do @_removeListeners
      filterModel = undefined
      activeComponents = undefined
      restrictions = undefined
      @activeComponents = undefined
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
  _addListeners = ->
    filterModel.on 'add change remove', _updateActiveComponents
    componentDefinitionsCollection.on 'add change remove', _updateActiveComponents
    instanceDefinitionsCollection.on 'add change remove', _updateActiveComponents

    activeComponents.on 'add', _onComponentAdded
    activeComponents.on 'change', _onComponentChange
    activeComponents.on 'remove', _onComponentRemoved
    activeComponents.on 'change:order', _onComponentOrderChange
    activeComponents.on 'change:targetName', _onComponentTargetNameChange

  _removeListeners = ->
    do activeComponents.off
    do filterModel.off
    do instanceDefinitionsCollection.off
    do componentDefinitionsCollection.off

  _previousElement = ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        _previousElement $el.prev(), order

  _updateActiveComponents = ->
    filterOptions = filterModel.toJSON()
    filterOptions.conditions = conditions
    instanceDefinitions = _filterInstanceDefinitions filterOptions
    activeComponents.set instanceDefinitions

    # check if we have any stray instances in active components and then try to readd them
    do _tryToReAddStraysToDom

  _filterInstanceDefinitions = (filterOptions) ->
    instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions filterOptions
    instanceDefinitions = _filterInstanceDefinitionsByShowCount instanceDefinitions
    instanceDefinitions = _filterInstanceDefinitionsByShowConditions instanceDefinitions
    return instanceDefinitions

  _filterInstanceDefinitionsByShowCount = (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
      showCount = instanceDefinition.get 'showCount'
      # maxShowCount on an instance level overrides maxShowCount on a componentDefinition level
      maxShowCount = instanceDefinition.get 'maxShowCount'
      shouldBeIncluded = true
      unless maxShowCount
        maxShowCount = componentDefinition.get 'maxShowCount'

      if maxShowCount
        if showCount < maxShowCount
          shouldBeIncluded = true
        else
          shouldBeIncluded = false

      return shouldBeIncluded

   _filterInstanceDefinitionsByShowConditions = (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
      componentConditions = componentDefinition.get 'conditions'
      shouldBeIncluded = true
      if componentConditions
        if _.isArray(componentConditions)
          for condition in componentConditions
            if not conditions[condition]()
              shouldBeIncluded = false
              return
        else if _.isString(componentConditions)
          shouldBeIncluded = conditions[componentConditions]()
      return shouldBeIncluded


  _getClass = (src) ->
    if _isUrl(src)
      componentClass = IframeComponent
      return componentClass
    else
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

    componentClassName = componentSettings.componentClassName or componentClassName

    hidden = componentSettings.hidden

    _registerComponents componentDefinitions
    _registerInstanceDefinitons instanceDefinitions

  _registerComponents = (componentDefinitions) ->
    componentDefinitionsCollection.set componentDefinitions,
      validate: true
      parse: true
      silent: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    instanceDefinitionsCollection.set instanceDefinitions,
      validate: true
      parse: true
      silent: true

  _addInstanceToModel = (instanceDefinition) ->
    componentDefinition = componentDefinitionsCollection.getByComponentId instanceDefinition.get('componentId')
    src = componentDefinition.get 'src'
    componentClass = _getClass src
    height = componentDefinition.get 'height'
    if instanceDefinition.get('height')
      height = instanceDefinition.get 'height'

    args =
      urlParams: instanceDefinition.get 'urlParams'
      urlParamsModel: instanceDefinition.get 'urlParamsModel'

    _.extend args, componentDefinition.get('args')
    _.extend args, instanceDefinition.get('args')

    if componentClass is IframeComponent
      args.src = src

    instance = new componentClass args
    instance.$el.addClass componentClassName

    if height
      instance.$el.style 'height', "#{height}px"

    instanceDefinition.set
      'instance': instance
    , silent: true

    return instanceDefinition

  _tryToReAddStraysToDom = ->
    strays = activeComponents.getStrays()
    for stray in strays
      render = false
      _addInstanceToDom stray, render
      do stray.get('instance').delegateEvents

  _addInstanceToDom = (instanceDefinition, render = true) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", $context
    instance = instanceDefinition.get 'instance'

    if render
      _renderInstance instanceDefinition

    _addInstanceInOrder instanceDefinition
    _incrementShowCount instanceDefinition
    _isComponentAreaEmpty $target

  _renderInstance = (instanceDefinition) ->
    instance = instanceDefinition.get 'instance'
    unless instance.render
      throw "The enstance #{instance.get('id')} does not have a render method"

    if instance.preRender? and _.isFunction(instance.preRender)
      do instance.preRender

    do instance.render

    if instance.postrender? and _.isFunction(instance.postRender)
      do instance.postRender

  _addInstanceInOrder = (instanceDefinition) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", $context
    order = instanceDefinition.get 'order'
    instance = instanceDefinition.get 'instance'

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

    if instanceDefinition.isAttached()
      if instance.onAddedToDom? and _.isFunction(instance.onAddedToDom)
        do instance.onAddedToDom

  _incrementShowCount = (instanceDefinition, silent = true) ->
    showCount = instanceDefinition.get 'showCount'
    showCount++
    instanceDefinition.set
      'showCount': showCount
    , silent: silent

  _disposeAndRemoveInstanceFromModel = (instanceDefinition) ->
    instance = instanceDefinition.get 'instance'
    do instance.dispose
    instance = undefined
    instanceDefinition.set
      'instance': undefined
    , { silent: true }

  _isUrl = (string) ->
    urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    return urlRegEx.test(string)

  _isComponentAreaEmpty = ($componentArea) ->
    isEmpty = $componentArea.length > 0
    $componentArea.addClass 'component-area--has-component', isEmpty
    return isEmpty

  #
  # Callbacks
  # ============================================================================
  _onComponentAdded = (instanceDefinition) ->
    _addInstanceToModel instanceDefinition
    _addInstanceToDom instanceDefinition

  _onComponentChange = (instanceDefinition) ->
    _disposeAndRemoveInstanceFromModel instanceDefinition
    _addInstanceToModel instanceDefinition
    _addInstanceToDom instanceDefinition

  _onComponentRemoved = (instanceDefinition) ->
    _disposeAndRemoveInstanceFromModel instanceDefinition
    $target = $ ".#{instanceDefinition.get('targetName')}", $context
    _isComponentAreaEmpty $target

  _onComponentOrderChange = (instanceDefinition) ->
    _addInstanceToDom instanceDefinition

  _onComponentTargetNameChange = (instanceDefinition) ->
    _addInstanceToDom instanceDefinition

  Vigor.componentManager = componentManager
