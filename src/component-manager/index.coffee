do ->

  componentClassName = 'vigor-component'
  targetPrefix = 'component-area'

  componentDefinitionsCollection = undefined
  instanceDefinitionsCollection = undefined
  activeInstancesCollection = undefined
  filterModel = undefined
  $context = undefined

  ERROR =
    UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'
    UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'

  EVENTS =
    ADD: 'add'
    CHANGE: 'change'
    REMOVE: 'remove'

    COMPONENT_ADD: 'component-add'
    COMPONENT_CHANGE: 'component-change'
    COMPONENT_REMOVE: 'component-remove'

    INSTANCE_ADD: 'instance-add'
    INSTANCE_CHANGE: 'instance-change'
    INSTANCE_REMOVE: 'instance-remove'

  componentManager =

    #
    # Public methods
    # ============================================================================
    initialize: (settings) ->
      componentDefinitionsCollection = new ComponentDefinitionsCollection()
      instanceDefinitionsCollection = new InstanceDefinitionsCollection()
      activeInstancesCollection = new ActiveInstancesCollection()
      filterModel = new FilterModel()

      # Expose methods and properties
      _.extend @, EVENTS

      do _addListeners

      if settings.$context
        $context = settings.$context
      else
        $context = $ 'body'

      conditions = settings.componentSettings.conditions
      if conditions and not _.isEmpty(conditions)
        silent = true
        @registerConditions settings.componentSettings.conditions, silent

      if settings.componentSettings
        _parseComponentSettings settings.componentSettings
      return @

    updateSettings: (settings) ->
      componentClassName = settings.componentClassName or componentClassName
      targetPrefix = settings.targetPrefix or targetPrefix
      return @

    refresh: (filterOptions) ->
      if filterOptions
        filterModel.set filterModel.parse(filterOptions)
      else
        do _updateActiveComponents
      return @

    serialize: ->
      return _serialize()

    addComponent: (componentDefinition) ->
      componentDefinitionsCollection.set componentDefinition,
        parse: true
        validate: true
        remove: false
      return @

    updateComponent: (componentId, attributes) ->
      componentDefinition = componentDefinitionsCollection.get componentId
      componentDefinition?.set attributes, validate: true
      return @

    removeComponent: (componentDefinitionId) ->
      instanceDefinitionsCollection.remove componentDefinitionId
      return @

    getComponentById: (componentId) ->
      return componentDefinitionsCollection.get(componentId)?.toJSON()

    getComponents: ->
      return componentDefinitionsCollection.toJSON()

    addInstance: (instanceDefinition) ->
      instanceDefinitionsCollection.set instanceDefinition,
        parse: true
        validate: true
        remove: false
      return @

    updateInstances: (instanceDefinitions) ->
      instanceDefinitionsCollection.set instanceDefinitions,
        parse: true
        validate: true
        remove: false
      return @

    removeInstance: (instanceId) ->
      instanceDefinitionsCollection.remove instanceId
      return @

    getInstanceById: (instanceId) ->
      return instanceDefinitionsCollection.get(instanceId)?.toJSON()

    getInstances: ->
      return instanceDefinitionsCollection.toJSON()

    getActiveInstances: ->
      instances = _.map activeInstancesCollection.models, (instanceDefinition) ->
        instance = instanceDefinition.get 'instance'
        unless instance
          _addInstanceToModel instanceDefinition
          instance = instanceDefinition.get 'instance'
        return instance
      return instances

    getTargetPrefix: ->
      return targetPrefix

    registerConditions: (conditionsToBeRegistered, silent = false) ->
      conditions = filterModel.get('conditions') or {}
      conditions = _.extend conditions, conditionsToBeRegistered
      filterModel.set
        'conditions': conditions
      , silent: silent
      return @

    getConditions: ->
      return filterModel.get 'conditions'

    clear: ->
      do componentDefinitionsCollection.reset
      do instanceDefinitionsCollection.reset
      do activeInstancesCollection.reset
      do filterModel.clear
      conditions = {}
      return @

    dispose: ->
      do @clear
      do @_removeListeners
      filterModel = undefined
      activeInstancesCollection = undefined
      conditions = undefined
      componentDefinitionsCollection = undefined

  #
  # Privat methods
  # ============================================================================
  _addListeners = ->
    filterModel.on 'change', _updateActiveComponents
    componentDefinitionsCollection.on 'add change remove', _updateActiveComponents
    instanceDefinitionsCollection.on 'add change remove', _updateActiveComponents

    activeInstancesCollection.on 'add', _onComponentAdded
    activeInstancesCollection.on 'change:componentId
                                  change:filterString
                                  change:conditions
                                  change:args
                                  change:showCount
                                  change:urlPattern
                                  change:urlParams
                                  change:reInstantiateOnUrlParamChange', _onComponentChange
    activeInstancesCollection.on 'change:order', _onComponentOrderChange
    activeInstancesCollection.on 'change:targetName', _onComponentTargetNameChange
    activeInstancesCollection.on 'remove', _onComponentRemoved

    # Propagate events
    # Component definitions
    componentDefinitionsCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_ADD, [model.toJSON(), collection.toJSON()]]

    componentDefinitionsCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_CHANGE, [model.toJSON()]]

    componentDefinitionsCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Instance definitions
    instanceDefinitionsCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_ADD, [model.toJSON(), collection.toJSON()]]

    instanceDefinitionsCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_CHANGE, [model.toJSON()]]

    instanceDefinitionsCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Active components
    activeInstancesCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.ADD, [model.toJSON(), collection.toJSON()]]

    activeInstancesCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.CHANGE, [model.toJSON()]]

    activeInstancesCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.REMOVE, [model.toJSON(), collection.toJSON()]]

  _removeListeners = ->
    do activeInstancesCollection.off
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
    instanceDefinitions = _filterInstanceDefinitions filterModel.toJSON()
    activeInstancesCollection.set instanceDefinitions

    # check if we have any stray instances in active components and then try to readd them
    do _tryToReAddStraysToDom

  _filterInstanceDefinitions = (filterOptions) ->
    instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions filterOptions
    instanceDefinitions = _filterInstanceDefinitionsByShowCount instanceDefinitions
    instanceDefinitions = _filterInstanceDefinitionsByComponentConditions instanceDefinitions
    return instanceDefinitions

  _filterInstanceDefinitionsByShowCount = (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = componentDefinitionsCollection.get instanceDefinition.get('componentId')
      unless componentDefinition
        throw ERROR.UNKNOWN_COMPONENT_DEFINITION
      componentMaxShowCount = componentDefinition.get 'maxShowCount'
      return instanceDefinition.exceedsMaximumShowCount componentMaxShowCount

  _filterInstanceDefinitionsByComponentConditions = (instanceDefinitions) ->
    globalConditions = filterModel.get 'conditions'
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = componentDefinitionsCollection.get instanceDefinition.get('componentId')
      return componentDefinition.areConditionsMet(globalConditions)

  _parseComponentSettings = (componentSettings) ->
    componentDefinitions = componentSettings.components or \
    componentSettings.widgets or \
    componentSettings.componentDefinitions

    instanceDefinitions = componentSettings.layoutsArray or \
    componentSettings.targets or \
    componentSettings.instanceDefinitions

    if componentSettings.settings
      componentManager.updateSettings componentSettings.settings

    hidden = componentSettings.hidden

    _registerComponents componentDefinitions
    _registerInstanceDefinitons instanceDefinitions

  _registerComponents = (componentDefinitions) ->
    componentDefinitionsCollection.set componentDefinitions,
      validate: true
      parse: true
      silent: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    instanceDefinitionsCollection.targetPrefix = targetPrefix
    instanceDefinitionsCollection.set instanceDefinitions,
      validate: true
      parse: true
      silent: true

  _addInstanceToModel = (instanceDefinition) ->
    componentDefinition = componentDefinitionsCollection.get instanceDefinition.get('componentId')
    componentClass = componentDefinition.getClass()
    height = componentDefinition.get 'height'
    if instanceDefinition.get('height')
      height = instanceDefinition.get 'height'

    args =
      urlParams: instanceDefinition.get 'urlParams'
      urlParamsModel: instanceDefinition.get 'urlParamsModel'

    componentArgs = componentDefinition.get 'args'
    instanceArgs = instanceDefinition.get 'args'

    if componentArgs?.iframeAttributes? and instanceArgs?.iframeAttributes?
      instanceArgs.iframeAttributes = _.extend componentArgs.iframeAttributes, instanceArgs.iframeAttributes

    _.extend args, componentArgs
    _.extend args, instanceArgs

    if componentClass is Vigor.IframeComponent
      args.src = componentDefinition.get 'src'

    instance = new componentClass args
    instance.$el.addClass componentClassName

    if height
      instance.$el.style 'height', "#{height}px"

    instanceDefinition.set
      'instance': instance
    , silent: true

    return instanceDefinition

  _tryToReAddStraysToDom = ->
    for stray in activeInstancesCollection.getStrays()
      render = false
      if instanceDefinition = _addInstanceToDom stray, render
        do instanceDefinition.dispose
      else
        do stray.get('instance').delegateEvents

  _addInstanceToDom = (instanceDefinition, render = true) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", $context

    if render
      do instanceDefinition.renderInstance

    if $target.length > 0
      _addInstanceInOrder instanceDefinition
      _isComponentAreaEmpty $target
    else
      return instanceDefinition

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

  _isComponentAreaEmpty = ($componentArea) ->
    isEmpty = $componentArea.length > 0
    $componentArea.toggleClass 'component-area--has-component', isEmpty
    return isEmpty

  _serialize = ->
    conditions = filterModel.get('conditions') or {}
    hidden = []
    components = componentDefinitionsCollection.toJSON()
    instances = instanceDefinitionsCollection.toJSON()
    componentSettings = {}

    for instanceDefinition in instances
      instanceDefinition.instance = undefined

    componentSettings =
      conditions: conditions
      components: components
      hidden: hidden
      instanceDefinitions: instances

    filter = (key, value) ->
      if typeof value is 'function'
          return value.toString()
      return value

    return JSON.stringify(componentSettings, filter, 2)

  #
  # Callbacks
  # ============================================================================
  _onComponentAdded = (instanceDefinition) ->
    _addInstanceToModel instanceDefinition
    _addInstanceToDom instanceDefinition
    do instanceDefinition.incrementShowCount

  _onComponentChange = (instanceDefinition) ->
    if instanceDefinition.passesFilter filterModel.toJSON()
      do instanceDefinition.disposeInstance
      _addInstanceToModel instanceDefinition
      _addInstanceToDom instanceDefinition

  _onComponentRemoved = (instanceDefinition) ->
    do instanceDefinition.disposeInstance
    $target = $ ".#{instanceDefinition.get('targetName')}", $context
    _isComponentAreaEmpty $target

  _onComponentOrderChange = (instanceDefinition) ->
    _addInstanceToDom instanceDefinition

  _onComponentTargetNameChange = (instanceDefinition) ->
    _addInstanceToDom instanceDefinition


  ### start-test-block ###
  # this will be removed in distribution build

  __testOnly = {}
  #classes
  __testOnly.ActiveInstancesCollection = ActiveInstancesCollection
  __testOnly.ComponentDefinitionsCollection = ComponentDefinitionsCollection
  __testOnly.ComponentDefinitionModel = ComponentDefinitionModel
  __testOnly.InstanceDefinitionsCollection = InstanceDefinitionsCollection
  __testOnly.InstanceDefinitionModel = InstanceDefinitionModel
  __testOnly.FilterModel = FilterModel
  __testOnly.IframeComponent = IframeComponent

  #properties
  __testOnly.componentClassName = componentClassName
  __testOnly.targetPrefix = targetPrefix
  __testOnly.componentDefinitionsCollection = componentDefinitionsCollection
  __testOnly.instanceDefinitionsCollection = instanceDefinitionsCollection
  __testOnly.activeInstancesCollection = activeInstancesCollection
  __testOnly.filterModel = filterModel
  __testOnly.$context = $context

  # mehtods
  __testOnly._addListeners = _addListeners
  __testOnly._removeListeners = _removeListeners
  __testOnly._previousElement = _previousElement
  __testOnly._updateActiveComponents = _updateActiveComponents
  __testOnly._filterInstanceDefinitions = _filterInstanceDefinitions
  __testOnly._filterInstanceDefinitionsByShowCount = _filterInstanceDefinitionsByShowCount
  __testOnly._filterInstanceDefinitionsByComponentConditions = _filterInstanceDefinitionsByComponentConditions
  __testOnly._parseComponentSettings = _parseComponentSettings
  __testOnly._registerComponents = _registerComponents
  __testOnly._registerInstanceDefinitons = _registerInstanceDefinitons
  __testOnly._addInstanceToModel = _addInstanceToModel
  __testOnly._tryToReAddStraysToDom = _tryToReAddStraysToDom
  __testOnly._addInstanceToDom = _addInstanceToDom
  __testOnly._addInstanceInOrder = _addInstanceInOrder
  __testOnly._isComponentAreaEmpty = _isComponentAreaEmpty

  # callbacks
  __testOnly._onComponentAdded = _onComponentAdded
  __testOnly._onComponentChange = _onComponentChange
  __testOnly._onComponentRemoved = _onComponentRemoved
  __testOnly._onComponentOrderChange = _onComponentOrderChange
  __testOnly._onComponentTargetNameChange = _onComponentOrderChange

  componentManager.__testOnly = __testOnly
  ### end-test-block ###

  _.extend componentManager, Backbone.Events
  Vigor.componentManager = componentManager

