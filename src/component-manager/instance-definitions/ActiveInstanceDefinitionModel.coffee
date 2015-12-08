class ActiveInstanceDefinitionModel extends BaseModel

  ERROR:
    MISSING_RENDER_METHOD: (id) ->
      return "The instance for #{id} does not have a render method"

  defaults:
    id: undefined
    componentClass: undefined
    target: undefined
    targetPrefix: undefined
    componentClassName: undefined
    instanceArguments: undefined
    order: undefined
    reInstantiate: false
    instance: undefined
    urlParams: undefined
    urlParamsCollection: undefined
    serializedFilter: undefined

  initialize: ->
    super
    @set 'urlParamsCollection', new UrlParamsCollection(), silent: true
    @on 'add', @_onAdd
    @on 'remove', @_onRemove
    @on 'change:instance', @_onInstanceChange
    @on 'change:urlParams', @_onUrlParamsChange
    @on 'change:order', @_onOrderChange
    @on 'change:target', @_onTargetChange
    @on 'change:serializedFilter', @_onSerializedFilterChange
    do @_updateUrlParamsCollection

  tryToReAddStraysToDom: ->
    if not @_isAttached()
      isAttached = do @_addInstanceInOrder
      if isAttached
        instance = @get 'instance'
        if instance?.delegateEvents and _.isFunction(instance?.delegateEvents)
          do instance.delegateEvents
      else
        do @_disposeInstance

      do @_updateTargetPopulatedState

  dispose: ->
    do @_disposeInstance
    do @_updateTargetPopulatedState
    do @off
    do @clear

  _createInstance: ->
    componentClass = @get 'componentClass'
    componentClassName = @get 'componentClassName'
    instance = new componentClass @_getInstanceArguments()
    instance.$el.addClass componentClassName
    @set 'instance', instance

  _renderInstance: ->
    instance = @get 'instance'
    unless instance then return
    unless instance.render? and _.isFunction(instance.render)
      throw @ERROR.MISSING_RENDER_METHOD @get('id')

    if instance.preRender? and _.isFunction(instance.preRender)
      do instance.preRender

    do instance.render

    if instance.postRender? and _.isFunction(instance.postRender)
      do instance.postRender

  _addInstanceInOrder: ->
    instance = @get 'instance'
    $target = @get 'target'
    order = @get 'order'
    isAttached = false

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

    isAttached = @_isAttached()

    if isAttached
      if instance.onAddedToDom? and _.isFunction(instance.onAddedToDom)
        do instance.onAddedToDom

    return isAttached

  _disposeInstance: ->
    instance = @get 'instance'
    if instance?.dispose?
      do instance.dispose
    instance = undefined
    @set 'instance', undefined, silent: true

  _isTargetPopulated: ->
    $target = @get 'target'
    return $target?.children().length > 0

  _updateTargetPopulatedState: ->
    $target = @get 'target'
    targetPrefix = @get 'targetPrefix'
    return $target?.toggleClass "#{targetPrefix}--has-components", @_isTargetPopulated()

  _isAttached: ->
    instance = @get 'instance'
    attached = false
    return attached unless instance

    if not instance.el and instance.$el
      el = instance.$el.get(0)
    else
      el = instance.el

    if instance
      attached = $.contains document.body, el
    return attached

  _getInstanceArguments: ->
    args = @get('instanceArguments') or {}
    args.urlParams = @get 'urlParams'
    args.urlParamsCollection = @get 'urlParamsCollection'
    return args

  _previousElement: ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        @_previousElement $el.prev(), order

  _updateUrlParamsCollection: ->
    urlParams = @get 'urlParams'
    urlParamsCollection = @get 'urlParamsCollection'
    urlParamsCollection.set urlParams

  _onInstanceChange: ->
    do @_renderInstance
    do @_addInstanceInOrder
    do @_updateTargetPopulatedState

  _onUrlParamsChange: ->
    do @_updateUrlParamsCollection

  _onOrderChange: ->
    do @_addInstanceInOrder

  _onTargetChange: ->
    do @_addInstanceInOrder

  _onSerializedFilterChange: ->
    if @get('reInstantiate')
      do @_disposeInstance
      do @_createInstance

  _onAdd: ->
    do @_createInstance

  _onRemove: ->
    do @dispose