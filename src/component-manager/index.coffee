do ->

  _componentClassName = 'vigor-component'
  _targetPrefix = 'component-area'

  _componentDefinitionsCollection = undefined
  _instanceDefinitionsCollection = undefined
  _activeInstancesCollection = undefined
  _filterModel = undefined
  _$context = undefined

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
      _componentDefinitionsCollection = new ComponentDefinitionsCollection()
      _instanceDefinitionsCollection = new InstanceDefinitionsCollection()
      _activeInstancesCollection = new ActiveInstancesCollection()
      _filterModel = new FilterModel()
      componentSettings = settings?.componentSettings

      _.extend @, EVENTS

      do _addListeners

      if settings?.$context
        _$context = settings.$context
      else
        _$context = $ 'body'

      conditions = componentSettings?.conditions
      if conditions and not _.isEmpty(conditions)
        silent = true
        @registerConditions conditions, silent

      if componentSettings
        _parseComponentSettings componentSettings
      return @

    updateSettings: (settings) ->
      _componentClassName = settings.componentClassName or _componentClassName
      _targetPrefix = settings.targetPrefix or _targetPrefix
      return @

    refresh: (filterOptions) ->
      if filterOptions
        _filterModel.set _filterModel.parse(filterOptions)
      else
        do _updateActiveComponents
      return @

    serialize: ->
      return _serialize()

    addComponents: (componentDefinition) ->
      _componentDefinitionsCollection.set componentDefinition,
        parse: true
        validate: true
        remove: false
      return @

    addInstance: (instanceDefinition) ->
      _instanceDefinitionsCollection.set instanceDefinition,
        parse: true
        validate: true
        remove: false
      return @

    updateComponents: (componentDefinitions) ->
      _componentDefinitionsCollection.set componentDefinitions,
        parse: true
        validate: true
        remove: false
      return @

    updateInstances: (instanceDefinitions) ->
      _instanceDefinitionsCollection.set instanceDefinitions,
        parse: true
        validate: true
        remove: false

      return @

    removeComponent: (componentDefinitionId) ->
      _instanceDefinitionsCollection.remove componentDefinitionId
      return @

    removeInstance: (instanceId) ->
      _instanceDefinitionsCollection.remove instanceId
      return @

    getComponentById: (componentId) ->
      return _componentDefinitionsCollection.get(componentId)?.toJSON()

    getInstanceById: (instanceId) ->
      return _instanceDefinitionsCollection.get(instanceId)?.toJSON()

    getComponents: ->
      return _componentDefinitionsCollection.toJSON()

    getInstances: ->
      return _instanceDefinitionsCollection.toJSON()

    getActiveInstances: ->
      instances = _.map _activeInstancesCollection.models, (instanceDefinition) ->
        instance = instanceDefinition.get 'instance'
        unless instance
          _addInstanceToModel instanceDefinition
          instance = instanceDefinition.get 'instance'
        return instance
      return instances

    getTargetPrefix: ->
      return _targetPrefix

    getConditions: ->
      return _filterModel.get 'conditions'

    registerConditions: (conditionsToBeRegistered, silent = false) ->
      conditions = _filterModel.get('conditions') or {}
      conditions = _.extend conditions, conditionsToBeRegistered
      _filterModel.set
        'conditions': conditions
      , silent: silent
      return @

    clear: ->
      do _componentDefinitionsCollection.reset
      do _instanceDefinitionsCollection.reset
      do _activeInstancesCollection.reset
      do _filterModel.clear
      return @

    dispose: ->
      do @clear
      do @_removeListeners
      _filterModel = undefined
      _activeInstancesCollection = undefined
      conditions = undefined
      _componentDefinitionsCollection = undefined

  #
  # Privat methods
  # ============================================================================
  _addListeners = ->
    _filterModel.on 'change', _updateActiveComponents
    _componentDefinitionsCollection.on 'throttled_diff', _updateActiveComponents
    _instanceDefinitionsCollection.on 'throttled_diff', _updateActiveComponents

    _activeInstancesCollection.on 'add', _onComponentAdded
    _activeInstancesCollection.on 'change:componentId
                                  change:filterString
                                  change:conditions
                                  change:args
                                  change:showCount
                                  change:urlPattern
                                  change:urlParams
                                  change:reInstantiateOnUrlParamChange', _onComponentChange
    _activeInstancesCollection.on 'change:order', _onComponentOrderChange
    _activeInstancesCollection.on 'change:targetName', _onComponentTargetNameChange
    _activeInstancesCollection.on 'remove', _onComponentRemoved

    # Propagate events
    # Component definitions
    _componentDefinitionsCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_ADD, [model.toJSON(), collection.toJSON()]]

    _componentDefinitionsCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_CHANGE, [model.toJSON()]]

    _componentDefinitionsCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.COMPONENT_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Instance definitions
    _instanceDefinitionsCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_ADD, [model.toJSON(), collection.toJSON()]]

    _instanceDefinitionsCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_CHANGE, [model.toJSON()]]

    _instanceDefinitionsCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.INSTANCE_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Active components
    _activeInstancesCollection.on 'add', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.ADD, [model.toJSON(), collection.toJSON()]]

    _activeInstancesCollection.on 'change', (model, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.CHANGE, [model.toJSON()]]

    _activeInstancesCollection.on 'remove', (model, collection, options) ->
      componentManager.trigger.apply componentManager, [EVENTS.REMOVE, [model.toJSON(), collection.toJSON()]]

  _removeListeners = ->
    do _activeInstancesCollection.off
    do _filterModel.off
    do _instanceDefinitionsCollection.off
    do _componentDefinitionsCollection.off

  _previousElement = ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        _previousElement $el.prev(), order

  _updateActiveComponents = ->
    instanceDefinitions = _filterInstanceDefinitions _filterModel.toJSON()
    _activeInstancesCollection.set instanceDefinitions

    # check if we have any stray instances in active components and then try to readd them
    do _tryToReAddStraysToDom

  _filterInstanceDefinitions = (filterOptions) ->
    instanceDefinitions = _instanceDefinitionsCollection.getInstanceDefinitions filterOptions
    instanceDefinitions = _filterInstanceDefinitionsByShowCount instanceDefinitions
    instanceDefinitions = _filterInstanceDefinitionsByComponentConditions instanceDefinitions
    return instanceDefinitions

  _filterInstanceDefinitionsByShowCount = (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = _componentDefinitionsCollection.get instanceDefinition.get('componentId')
      unless componentDefinition
        throw ERROR.UNKNOWN_COMPONENT_DEFINITION
      componentMaxShowCount = componentDefinition.get 'maxShowCount'
      return not instanceDefinition.exceedsMaximumShowCount componentMaxShowCount

  _filterInstanceDefinitionsByComponentConditions = (instanceDefinitions) ->
    globalConditions = _filterModel.get 'conditions'
    _.filter instanceDefinitions, (instanceDefinition) ->
      componentDefinition = _componentDefinitionsCollection.get instanceDefinition.get('componentId')
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
    _componentDefinitionsCollection.set componentDefinitions,
      validate: true
      parse: true
      silent: true

  _registerInstanceDefinitons = (instanceDefinitions) ->
    _instanceDefinitionsCollection.setTargetPrefix _targetPrefix
    _instanceDefinitionsCollection.set instanceDefinitions,
      validate: true
      parse: true
      silent: true

  _addInstanceToModel = (instanceDefinition) ->
    componentDefinition = _componentDefinitionsCollection.get instanceDefinition.get('componentId')
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
    instance.$el.addClass _componentClassName

    if height
      instance.$el.style 'height', "#{height}px"

    instanceDefinition.set
      'instance': instance
    , silent: true

    return instanceDefinition

  _tryToReAddStraysToDom = ->
    for stray in _activeInstancesCollection.getStrays()
      render = false
      if _addInstanceToDom(stray, render)
        instance = stray.get 'instance'
        if instance?.delegateEvents?
          do instance.delegateEvents
      else
        do stray.disposeInstance

  _addInstanceToDom = (instanceDefinition, render = true) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", _$context
    success = false

    if render
      do instanceDefinition.renderInstance

    if $target.length > 0
      _addInstanceInOrder instanceDefinition
      _isComponentAreaEmpty $target
      success = true

    return success

  _addInstanceInOrder = (instanceDefinition) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", _$context
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
    conditions = _filterModel.get('conditions') or {}
    hidden = []
    components = _componentDefinitionsCollection.toJSON()
    instances = _instanceDefinitionsCollection.toJSON()
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
    if instanceDefinition.passesFilter _filterModel.toJSON()
      do instanceDefinition.disposeInstance
      _addInstanceToModel instanceDefinition
      _addInstanceToDom instanceDefinition

  _onComponentRemoved = (instanceDefinition) ->
    do instanceDefinition.disposeInstance
    $target = $ ".#{instanceDefinition.get('targetName')}", _$context
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
  __testOnly.router = Router
  __testOnly._componentClassName = _componentClassName
  __testOnly._targetPrefix = _targetPrefix
  __testOnly._componentDefinitionsCollection = _componentDefinitionsCollection
  __testOnly._instanceDefinitionsCollection = _instanceDefinitionsCollection
  __testOnly._activeInstancesCollection = _activeInstancesCollection
  __testOnly._filterModel = _filterModel
  __testOnly._$context = _$context

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

