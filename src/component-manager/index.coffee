class ComponentManager

  COMPONENT_CLASS_NAME = 'vigor-component'
  TARGET_PREFIX = 'component-area'

  ERROR:
    CONDITION:
      WRONG_FORMAT: 'condition has to be an object with key value pairs'
    MESSAGE:
      MISSING_ID: 'The id of targeted instance must be passed as first argument'
      MISSING_MESSAGE: 'No message was passed'
      MISSING_RECEIVE_MESSAGE_METHOD: 'The instance does not seem to have a receiveMessage method'
    CONTEXT:
      WRONG_FORMAT: 'context should be a string or a jquery object'

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

  refresh: (filter) ->
    @_filterModel.set @_filterModel.parse(filter)
    return @_updateActiveComponents()

  serialize: ->
    componentSettings = {}
    conditions = @_globalConditionsModel.toJSON()
    componentDefinitions = @_componentDefinitionsCollection.toJSON()
    instanceDefinitions = @_instanceDefinitionsCollection.toJSON()

    for componentDefinition in componentDefinitions
      componentDefinition.componentClass = undefined

    $context = @getContext()
    if $context.length > 0
      tagName = $context.prop('tagName').toLowerCase()
      classes = $context.attr('class')?.replace ' ', '.'
      contextSelector = $context.selector or "#{tagName}.#{classes}"
    else
      contextSelector = 'body'

    settings =
      context: contextSelector
      componentClassName: @getComponentClassName()
      targetPrefix: @getTargetPrefix()
      componentSettings:
        conditions: conditions
        components: componentDefinitions
        instances: instanceDefinitions

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
    @_filterModel?.clear silent: true
    @_globalConditionsModel?.clear silent: true
    @_$context = undefined
    @_componentClassName = COMPONENT_CLASS_NAME
    @_targetPrefix = TARGET_PREFIX
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
    @_componentDefinitionsCollection.on 'throttled_diff', @_updateActiveComponents
    @_instanceDefinitionsCollection.on 'throttled_diff', @_updateActiveComponents
    @_globalConditionsModel.on 'change', @_updateActiveComponents
    @_activeInstancesCollection.on 'add', @_onActiveInstanceAdd

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

  addComponentDefinitions: (componentDefinitions) ->
    @_componentDefinitionsCollection.set componentDefinitions,
      parse: true
      validate: true
      remove: false
    return @

  addInstanceDefinitions: (instanceDefinitions) ->
    data =
      instanceDefinitions: instanceDefinitions
      targetPrefix: @getTargetPrefix()

    @_instanceDefinitionsCollection.set data,
      parse: true
      validate: true
      remove: false
    return @

  updateComponentDefinitions: (componentDefinitions) ->
    @addComponentDefinitions componentDefinitions
    return @

  updateInstanceDefinitions: (instanceDefinitions) ->
    @addInstanceDefinitions instanceDefinitions
    return @

  removeComponentDefinition: (componentDefinitionId) ->
    @_componentDefinitionsCollection.remove componentDefinitionId
    return @

  removeInstanceDefinition: (instanceDefinitionId) ->
    @_instanceDefinitionsCollection.remove instanceDefinitionId
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

  setContext: (context = 'body') ->
    if _.isString(context)
      @_$context = $ context
    else if context.jquery?
      @_$context = context
    else
      throw @ERROR.CONTEXT.WRONG_FORMAT
    return @

  setComponentClassName: (@_componentClassName = COMPONENT_CLASS_NAME) ->
    return @

  setTargetPrefix: (@_targetPrefix = TARGET_PREFIX) ->
    return @

  getContext: ->
    return @_$context

  getComponentClassName: ->
    return @_componentClassName

  getTargetPrefix: ->
    return @_targetPrefix or TARGET_PREFIX

  getActiveFilter: ->
    return @_filterModel.toJSON()

  getConditions: ->
    return @_globalConditionsModel.toJSON()

  getComponentDefinitionById: (componentDefinitionId) ->
    return @_componentDefinitionsCollection.getComponentDefinitionById(componentDefinitionId).toJSON()

  getInstanceDefinitionById: (instanceDefinitionId) ->
    return @_instanceDefinitionsCollection.getInstanceDefinition(instanceDefinitionId).toJSON()

  getComponentDefinitions: ->
    return @_componentDefinitionsCollection.toJSON()

  getInstanceDefinitions: ->
    return @_instanceDefinitionsCollection.toJSON()

  getActiveInstances: ->
    return @_mapInstances @_activeInstancesCollection.models

  getActiveInstanceById: (instanceDefinitionId) ->
    return @_activeInstancesCollection.getInstanceDefinition(instanceDefinitionId)?.get 'instance'

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
    @setContext settings?.context

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
    data =
      instanceDefinitions: instanceDefinitions
      targetPrefix: @getTargetPrefix()

    @_instanceDefinitionsCollection.set data,
      validate: true
      parse: true
      silent: true

    return @

  _updateActiveComponents: =>
    deferred = $.Deferred()
    options = @_filterModel.get 'options'
    instanceDefinitions = @_filterInstanceDefinitions()

    if options.invert
      instanceDefinitions = _.difference @_instanceDefinitionsCollection.models, instanceDefinitions

    componentClassPromises = @_componentDefinitionsCollection.getComponentClassPromisesByInstanceDefinitions instanceDefinitions

    $.when.apply($, componentClassPromises).then =>
      activeInstanceDefinitionObjs = @_createActiveInstanceDefinitionObjects instanceDefinitions

      lastChange = @_activeInstancesCollection.set activeInstanceDefinitionObjs, options
      _.invoke lastChange, 'tryToReAddStraysToDom'

      returnData =
        filter: @_filterModel.toJSON()
        activeInstances: @_mapInstances @_activeInstancesCollection.models
        activeInstanceDefinitions: @_activeInstancesCollection.toJSON()
        lastChangedInstances: @_mapInstances lastChange
        lastChangedInstanceDefinitions: @_modelsToJSON lastChange

      deferred.resolve returnData

    return deferred.promise()

  _createActiveInstanceDefinitionObjects: (instanceDefinitions) ->
    excludeOptions = true
    url = @_filterModel.get 'url'
    options = @_filterModel.get 'options'
    serializedFilter = @_filterModel.serialize excludeOptions
    targetPrefix = do @getTargetPrefix
    componentClassName = do @getComponentClassName
    $context = do @getContext

    unless _.isArray(instanceDefinitions)
      instanceDefinitions = [instanceDefinitions]

    activeInstanceDefinitionObjs = _.map instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition

      id = instanceDefinition.id
      componentClass = componentDefinition.get 'componentClass'
      target = instanceDefinition.getTarget $context
      instanceArguments = @_getInstanceArguments instanceDefinition, componentDefinition
      order = instanceDefinition.get 'order'
      reInstantiate = instanceDefinition.get 'reInstantiate'
      urlPattern = instanceDefinition.get 'urlPattern'
      urlParams = undefined

      if urlPattern
        urlParams = router.getArguments urlPattern, url
      else
        urlParams =
          _id: 'noUrlPatternsDefined'
          url: url

      activeInstanceObj =
        id: id
        componentClass: componentClass
        target: target
        targetPrefix: targetPrefix
        componentClassName: componentClassName
        instanceArguments: instanceArguments
        order: order
        reInstantiate: reInstantiate
        urlParams: urlParams
        serializedFilter: serializedFilter

      return activeInstanceObj

    return activeInstanceDefinitionObjs

  _filterInstanceDefinitions: ->
    instanceDefinitions = @_instanceDefinitionsCollection.models
    instanceDefinitions = @_filterInstanceDefinitionsByComponentLevelFilters instanceDefinitions
    instanceDefinitions = @_filterInstanceDefinitionsByInstanceLevelFilters instanceDefinitions
    instanceDefinitions = @_filterInstanceDefinitionsByCustomProperties instanceDefinitions
    instanceDefinitions = @_filterInstanceDefinitionsByShowCount instanceDefinitions
    instanceDefinitions = @_filterInstanceDefinitionsByTargetAvailability instanceDefinitions
    return instanceDefinitions

  _filterInstanceDefinitionsByComponentLevelFilters: (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      return componentDefinition.passesFilter @_filterModel, @_globalConditionsModel

  _filterInstanceDefinitionsByInstanceLevelFilters: (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) =>
      return instanceDefinition.passesFilter @_filterModel, @_globalConditionsModel

  _filterInstanceDefinitionsByCustomProperties: (instanceDefinitions) ->
    customFilterProperteis = @_filterModel.getCustomProperties()
    _.filter instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      customProperties = _.extend {}, componentDefinition.getCustomProperties(), instanceDefinition.getCustomProperties()
      if not _.isEmpty(customFilterProperteis)
        return _.isMatch customProperties, customFilterProperteis
      else
        return true

  _filterInstanceDefinitionsByShowCount: (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) =>
      componentDefinition = @_componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition instanceDefinition
      componentMaxShowCount = componentDefinition.get 'maxShowCount'
      return not instanceDefinition.exceedsMaximumShowCount componentMaxShowCount

  _filterInstanceDefinitionsByTargetAvailability: (instanceDefinitions) ->
    _.filter instanceDefinitions, (instanceDefinition) =>
      return instanceDefinition.isTargetAvailable @getContext()

  _getInstanceArguments: (instanceDefinition, componentDefinition) ->
    componentClass = componentDefinition.get 'componentClass'
    args = {}

    componentArgs = componentDefinition.get 'args'
    instanceArgs = instanceDefinition.get 'args'

    if componentArgs?.iframeAttributes? and instanceArgs?.iframeAttributes?
      instanceArgs.iframeAttributes = _.extend componentArgs.iframeAttributes, instanceArgs.iframeAttributes

    _.extend args, componentArgs, instanceArgs

    if componentClass is Vigor.IframeComponent
      args.src = componentDefinition.get 'src'

    return args

  _mapInstances: (instanceDefinitions) ->
    unless _.isArray(instanceDefinitions)
      instanceDefinitions = [instanceDefinitions]

    instanceDefinitions = _.compact instanceDefinitions

    instances = _.map instanceDefinitions, (instanceDefinition) =>
      return instanceDefinition.get 'instance'

    return _.compact(instances)

  _modelToJSON: (model) ->
    return model.toJSON()

  _modelsToJSON: (models) ->
    _.map models, @_modelToJSON

  #
  # Callbacks
  # ============================================================================
  _onActiveInstanceAdd: (activeInstanceDefinition) =>
    instanceDefinition = @_instanceDefinitionsCollection.get activeInstanceDefinition.id
    do instanceDefinition.incrementShowCount

  _onMessageReceived: (event) =>
    id = event?.data?.id
    message = event?.data?.message

    unless id
      throw @ERROR.MESSAGE.MISSING_ID

    unless message
      throw @ERROR.MESSAGE.MISSING_MESSAGE

    @postMessageToInstance id, message

### start-test-block ###
# this will be removed in distribution build
__testOnly = {}

#classes
__testOnly.ActiveInstancesCollection = ActiveInstancesCollection
__testOnly.ComponentDefinitionsCollection = ComponentDefinitionsCollection
__testOnly.ComponentDefinitionModel = ComponentDefinitionModel
__testOnly.InstanceDefinitionsCollection = InstanceDefinitionsCollection
__testOnly.InstanceDefinitionModel = InstanceDefinitionModel
__testOnly.ActiveInstanceDefinitionModel = ActiveInstanceDefinitionModel
__testOnly.FilterModel = FilterModel
__testOnly.IframeComponent = IframeComponent
__testOnly.BaseCollection = BaseCollection
__testOnly.BaseModel = BaseModel
__testOnly.BaseInstanceCollection = BaseInstanceCollection

#properties
__testOnly.router = Router

ComponentManager.__testOnly = __testOnly
### end-test-block ###

_.extend ComponentManager.prototype, Backbone.Events
Vigor.ComponentManager = ComponentManager
