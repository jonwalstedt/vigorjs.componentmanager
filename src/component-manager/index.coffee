class ComponentManager

  _defaultComponentClassName = 'vigor-component'
  _defaultTargetPrefix = 'component-area'

  ERROR:
    CONDITION:
      WRONG_FORMAT: 'condition has to be an object with key value pairs'
    MESSAGE:
      MISSING_ID: 'The id of targeted instance must be passed as first argument'
      MISSING_MESSAGE: 'No message was passed'
      MISSING_RECEIVE_MESSAGE_METHOD: 'The instance does not seem to have a receiveMessage method'

  EVENTS:
    ADD: 'add'
    CHANGE: 'change'
    REMOVE: 'remove'

    COMPONENT_ADD: 'component-add'
    COMPONENT_CHANGE: 'component-change'
    COMPONENT_REMOVE: 'component-remove'

    INSTANCE_ADD: 'instance-add'
    INSTANCE_CHANGE: 'instance-change'
    INSTANCE_REMOVE: 'instance-remove'

  _componentDefinitionsCollection: undefined
  _instanceDefinitionsCollection: undefined
  _activeInstancesCollection: undefined
  _globalConditionsModel: undefined
  _filterModel: undefined

  _$context: undefined
  _componentClassName: undefined
  _targetPrefix: undefined
  _listenForMessages: false

  #
  # Public methods
  # ============================================================================
  initialize: (settings) ->
    @_componentDefinitionsCollection = new ComponentDefinitionsCollection()
    @_instanceDefinitionsCollection = new InstanceDefinitionsCollection()
    @_activeInstancesCollection = new ActiveInstancesCollection()
    @_globalConditionsModel = new Backbone.Model()
    @_filterModel = new FilterModel()

    do @setComponentClassName
    do @setTargetPrefix

    if settings?.listenForMessages
      @_listenForMessages = true

    do @addListeners
    @_parse settings
    return @

  updateSettings: (settings) ->
    @_parse settings
    return @

  refresh: (filter, cb = undefined) ->
    if filter
      @_filterModel.set @_filterModel.parse(filter)
    else
      do @_filterModel?.clear
      do @_updateActiveComponents
    if cb
      cb filter, @getActiveInstances()
    return @

  serialize: ->
    hidden = []
    componentSettings = {}
    conditions = @_globalConditionsModel.toJSON()
    components = @_componentDefinitionsCollection.toJSON()
    instances = @_instanceDefinitionsCollection.toJSON()

    for instanceDefinition in instances
      instanceDefinition.instance = undefined

    $context = @getContext()
    if $context.length > 0
      tagName = $context.prop('tagName').toLowerCase()
      classes = $context.attr('class')?.replace ' ', '.'
      contextSelector = $context.selector or "#{tagName}.#{classes}"
    else
      contextSelector = 'body'

    settings =
      $context: contextSelector
      componentClassName: @getComponentClassName()
      targetPrefix: @getTargetPrefix()
      componentSettings:
        conditions: conditions
        components: components
        hidden: hidden
        instances: instances

    filter = (key, value) ->
      if typeof value is 'function'
          return value.toString()
      return value

    return JSON.stringify settings, filter

  parse: (jsonString, updateSettings = false) ->
    filter = (key, value) ->
      isString = value and typeof value is 'string'
      isFunction = isString and value.substr(0, 8) is 'function'
      if isString and isFunction
        startBody = value.indexOf('{') + 1
        endBody = value.lastIndexOf '}'
        startArgs = value.indexOf('(') + 1
        endArgs = value.indexOf ')'

        args = value.substring(startArgs, endArgs)
        body = value.substring(startBody, endBody)
        return new Function(args, body)
      return value

    settings = JSON.parse jsonString, filter

    if updateSettings
      @updateSettings settings

    return settings

  clear: ->
    do @_componentDefinitionsCollection?.reset
    do @_instanceDefinitionsCollection?.reset
    do @_activeInstancesCollection?.reset
    do @_filterModel?.clear
    do @_globalConditionsModel?.clear
    @_$context = undefined
    @_componentClassName = 'vigor-component'
    @_targetPrefix = 'component-area'
    return @

  dispose: ->
    do @clear
    do @removeListeners
    @_componentDefinitionsCollection = undefined
    @_instanceDefinitionsCollection = undefined
    @_globalConditionsModel = undefined
    @_activeInstancesCollection = undefined
    @_filterModel = undefined

  addListeners: ->
    @_filterModel.on 'change', @_updateActiveComponents
    @_componentDefinitionsCollection.on 'throttled_diff', @_updateActiveComponents
    @_instanceDefinitionsCollection.on 'throttled_diff', @_updateActiveComponents
    @_globalConditionsModel.on 'change', @_updateActiveComponents

    @_activeInstancesCollection.on 'add', @_onActiveInstanceAdd
    @_activeInstancesCollection.on 'change:componentId
                                  change:filterString
                                  change:conditions
                                  change:args
                                  change:showCount
                                  change:urlPattern
                                  change:urlParams
                                  change:reInstantiateOnUrlParamChange', @_onActiveInstanceChange
    @_activeInstancesCollection.on 'change:order', @_onActiveInstanceOrderChange
    @_activeInstancesCollection.on 'change:targetName', @_onActiveInstanceTargetNameChange
    @_activeInstancesCollection.on 'remove', @_onActiveInstanceRemoved

    # Propagate events
    # Component definitions
    @_componentDefinitionsCollection.on 'add', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.COMPONENT_ADD, [model.toJSON(), collection.toJSON()]]

    @_componentDefinitionsCollection.on 'change', (model, options) =>
      @trigger.apply @, [@EVENTS.COMPONENT_CHANGE, [model.toJSON()]]

    @_componentDefinitionsCollection.on 'remove', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.COMPONENT_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Instance definitions
    @_instanceDefinitionsCollection.on 'add', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.INSTANCE_ADD, [model.toJSON(), collection.toJSON()]]

    @_instanceDefinitionsCollection.on 'change', (model, options) =>
      @trigger.apply @, [@EVENTS.INSTANCE_CHANGE, [model.toJSON()]]

    @_instanceDefinitionsCollection.on 'remove', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.INSTANCE_REMOVE, [model.toJSON(), collection.toJSON()]]

    # Active components
    @_activeInstancesCollection.on 'add', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.ADD, [model.toJSON(), collection.toJSON()]]

    @_activeInstancesCollection.on 'change', (model, options) =>
      @trigger.apply @, [@EVENTS.CHANGE, [model.toJSON()]]

    @_activeInstancesCollection.on 'remove', (model, collection, options) =>
      @trigger.apply @, [@EVENTS.REMOVE, [model.toJSON(), collection.toJSON()]]

    if @_listenForMessages
      eventMethod = if window.addEventListener then 'addEventListener' else 'attachEvent'
      eventer = window[eventMethod]
      messageEvent = if eventMethod is 'attachEvent' then 'onmessage' else 'message'

      eventer messageEvent, @_onMessageReceived, false

    return @

  addConditions: (conditions, silent = false) ->
    if _.isObject(conditions)
      existingConditions = @_globalConditionsModel.get('conditions') or {}
      conditions = _.extend existingConditions, conditions

      @_globalConditionsModel.set conditions, silent: silent
    else
      throw @ERROR.CONDITION.WRONG_FORMAT
    return @

  addComponents: (componentDefinitions) ->
    @_componentDefinitionsCollection.set componentDefinitions,
      parse: true
      validate: true
      remove: false
    return @

  addInstances: (instanceDefinitions) ->
    @_instanceDefinitionsCollection.set instanceDefinitions,
      parse: true
      validate: true
      remove: false
    return @

  updateComponents: (componentDefinitions) ->
    @addComponents componentDefinitions
    return @

  updateInstances: (instanceDefinitions) ->
    @addInstances instanceDefinitions
    return @

  removeComponent: (componentDefinitionId) ->
    @_componentDefinitionsCollection.remove componentDefinitionId
    return @

  removeInstance: (instanceId) ->
    @_instanceDefinitionsCollection.remove instanceId
    return @

  removeListeners: ->
    do @_activeInstancesCollection?.off
    do @_filterModel?.off
    do @_instanceDefinitionsCollection?.off
    do @_componentDefinitionsCollection?.off
    do @_globalConditionsModel?.off

    if @_listenForMessages
      eventMethod = if window.removeEventListener then 'removeEventListener' else 'detachEvent'
      eventer = window[eventMethod]
      messageEvent = if eventMethod is 'detachEvent' then 'onmessage' else 'message'
      eventer messageEvent, @_onMessageReceived

    return @

  setContext: (context) ->
    if _.isString(context)
      @_$context = $ context
    else
      @_$context = context
    return @

  setComponentClassName: (componentClassName) ->
    @_componentClassName = componentClassName or _defaultComponentClassName
    return @

  setTargetPrefix: (targetPrefix) ->
    @_targetPrefix = targetPrefix or _defaultTargetPrefix
    return @

  getContext: ->
    return @_$context

  getComponentClassName: ->
    return @_componentClassName

  getTargetPrefix: ->
    return @_targetPrefix

  getActiveFilter: ->
    return @_filterModel.toJSON()

  getConditions: ->
    return @_globalConditionsModel.toJSON()

  getComponentById: (componentId) ->
    return @_componentDefinitionsCollection.getComponentDefinitionById(componentId).toJSON()

  getInstanceById: (instanceId) ->
    return @_instanceDefinitionsCollection.getInstanceDefinition(instanceId).toJSON()

  getComponents: ->
    return @_componentDefinitionsCollection.toJSON()

  getInstances: ->
    return @_instanceDefinitionsCollection.toJSON()

  getActiveInstances: ->
    instances = _.map @_activeInstancesCollection.models, (instanceDefinition) =>
      instance = instanceDefinition.get 'instance'
      unless instance
        @_addInstanceToModel instanceDefinition
        instance = instanceDefinition.get 'instance'
      return instance
    return instances

  getActiveInstanceById: (instanceId) ->
    return @_activeInstancesCollection.getInstanceDefinition(instanceId)?.get 'instance'

  postMessageToInstance: (id, message) ->
    unless id
      throw @ERROR.MESSAGE.MISSING_ID

    unless message
      throw @ERROR.MESSAGE.MISSING_MESSAGE

    instance = @getActiveInstanceById id
    if _.isFunction(instance?.receiveMessage)
      instance.receiveMessage message
    else
      throw @ERROR.MESSAGE.MISSING_RECEIVE_MESSAGE_METHOD
  #
  # Privat methods
  # ============================================================================
  _parse: (settings) ->
    if settings?.$context
      @setContext settings.$context
    else
      @setContext $('body')

    if settings?.componentClassName
      @setComponentClassName settings.componentClassName

    if settings?.targetPrefix
      @setTargetPrefix settings.targetPrefix

    if settings?.componentSettings
      @_parseComponentSettings settings.componentSettings
    else
      if settings
        @_parseComponentSettings settings

    return @

  _parseComponentSettings: (componentSettings) ->
    componentDefinitions = componentSettings.components or \
    componentSettings.widgets or \
    componentSettings.componentDefinitions

    instanceDefinitions = componentSettings.layoutsArray or \
    componentSettings.targets or \
    componentSettings.instanceDefinitions or \
    componentSettings.instances

    silent = true
    hidden = componentSettings.hidden

    if componentSettings.conditions
      conditions = componentSettings.conditions

      if _.isObject(conditions) and not _.isEmpty(conditions)
        @addConditions conditions, silent

    if componentDefinitions
      @_registerComponentDefinitions componentDefinitions

    if instanceDefinitions
      @_registerInstanceDefinitions instanceDefinitions

    return @

  _registerComponentDefinitions: (componentDefinitions) ->
    @_componentDefinitionsCollection.set componentDefinitions,
      validate: true
      parse: true
      silent: true
    return @

  _registerInstanceDefinitions: (instanceDefinitions) ->
    @_instanceDefinitionsCollection.setTargetPrefix @getTargetPrefix()
    @_instanceDefinitionsCollection.set instanceDefinitions,
      validate: true
      parse: true
      silent: true
    return @

  _previousElement: ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        @_previousElement $el.prev(), order

  _updateActiveComponents: =>
    instanceDefinitions = @_filterInstanceDefinitions @_filterModel.toJSON()
    @_activeInstancesCollection.set instanceDefinitions

    # check if we have any stray instances in active components and then try to readd them
    do @_tryToReAddStraysToDom
    return @

  _filterInstanceDefinitions: (filterOptions) ->
    globalConditions = @_globalConditionsModel.toJSON()
    instanceDefinitions = @_instanceDefinitionsCollection.getInstanceDefinitions filterOptions, globalConditions
    instanceDefinitions = @_filterInstanceDefinitionsByShowCount instanceDefinitions
    instanceDefinitions = @_filterInstanceDefinitionsByConditions instanceDefinitions
    return instanceDefinitions

  _filterInstanceDefinitionsByShowCount: (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      componentMaxShowCount = componentDefinition.get 'maxShowCount'
      return not instanceDefinition.exceedsMaximumShowCount componentMaxShowCount

  _filterInstanceDefinitionsByConditions: (instanceDefinitions) ->
    globalConditions = @_globalConditionsModel.toJSON()
    _.filter instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      return componentDefinition.areConditionsMet globalConditions

  _getInstanceHeight: (instanceDefinition) ->
    componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
    height = componentDefinition.get 'height'
    if instanceDefinition.get('height')
      height = instanceDefinition.get 'height'
    return height

  _getInstanceArguments: (instanceDefinition) ->
    args =
      urlParams: instanceDefinition.get 'urlParams'
      urlParamsModel: instanceDefinition.get 'urlParamsModel'

    componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
    componentClass = @_componentDefinitionsCollection.getComponentClassByInstanceDefinition instanceDefinition

    componentArgs = componentDefinition.get 'args'
    instanceArgs = instanceDefinition.get 'args'

    if componentArgs?.iframeAttributes? and instanceArgs?.iframeAttributes?
      instanceArgs.iframeAttributes = _.extend componentArgs.iframeAttributes, instanceArgs.iframeAttributes

    _.extend args, componentArgs
    _.extend args, instanceArgs

    if componentClass is Vigor.IframeComponent
      args.src = componentDefinition.get 'src'

    return args

  _addInstanceToModel: (instanceDefinition) ->
    componentClass = @_componentDefinitionsCollection.getComponentClassByInstanceDefinition instanceDefinition

    instance = new componentClass @_getInstanceArguments(instanceDefinition)
    instance.$el.addClass @getComponentClassName()

    if height = @_getInstanceHeight(instanceDefinition)
      instance.$el.css 'height', "#{height}px"

    instanceDefinition.set
      'instance': instance
    , silent: true

    return instanceDefinition

  _tryToReAddStraysToDom: ->
    for stray in @_activeInstancesCollection.getStrays()
      render = false
      if @_addInstanceToDom(stray, render)
        instance = stray.get 'instance'
        if instance?.delegateEvents and _.isFunction(instance?.delegateEvents)
          do instance.delegateEvents
      else
        do stray.disposeInstance

  _addInstanceToDom: (instanceDefinition, render = true) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", @_$context

    if render
      do instanceDefinition.renderInstance

    if $target.length > 0
      @_addInstanceInOrder instanceDefinition
      @_setComponentAreaPopulatedState $target

    return instanceDefinition.isAttached()

  _addInstanceInOrder: (instanceDefinition) ->
    $target = $ ".#{instanceDefinition.get('targetName')}", @_$context
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
        $previousElement = @_previousElement $target.children().last(), order
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

    return @

  _isComponentAreaPopulated: ($componentArea) ->
    $componentArea.children().length > 0

  _setComponentAreaPopulatedState: ($componentArea) ->
    $componentArea.toggleClass "#{@_targetPrefix}--has-components", @_isComponentAreaPopulated($componentArea)

  #
  # Callbacks
  # ============================================================================
  _onActiveInstanceAdd: (instanceDefinition) =>
    @_addInstanceToModel instanceDefinition
    @_addInstanceToDom instanceDefinition
    do instanceDefinition.incrementShowCount

  _onActiveInstanceChange: (instanceDefinition) =>
    filter = @_filterModel.toJSON()
    globalConditions = @_globalConditionsModel.toJSON()
    if instanceDefinition.passesFilter filter, globalConditions
      do instanceDefinition.disposeInstance
      @_addInstanceToModel instanceDefinition
      @_addInstanceToDom instanceDefinition

  _onActiveInstanceRemoved: (instanceDefinition) =>
    do instanceDefinition.disposeInstance
    $target = $ ".#{instanceDefinition.get('targetName')}", @_$context
    @_setComponentAreaPopulatedState $target

  _onActiveInstanceOrderChange: (instanceDefinition) =>
    @_addInstanceToDom instanceDefinition

  _onActiveInstanceTargetNameChange: (instanceDefinition) =>
    @_addInstanceToDom instanceDefinition

  _onMessageReceived: (event) =>
    id = event.data.id
    data = event.data.data
    @postMessageToInstance id, data

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
__testOnly.BaseCollection = BaseCollection
__testOnly.BaseInstanceCollection = BaseInstanceCollection

#properties
__testOnly.router = Router

ComponentManager.__testOnly = __testOnly
### end-test-block ###

_.extend ComponentManager.prototype, Backbone.Events
Vigor.ComponentManager = ComponentManager
