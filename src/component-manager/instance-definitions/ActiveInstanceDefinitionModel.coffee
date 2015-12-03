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
    urlParamsModel: new Backbone.Model()
    serializedFilter: undefined

  initialize: ->
    super
    @on 'add', @_onAdd
    @on 'remove', @_onRemove
    @on 'change:instance', @_onInstanceChange
    @on 'change:urlParams', @_onUrlParamsChange
    @on 'change:order', @_onOrderChange
    @on 'change:target', @_onTargetChange
    @on 'change:serializedFilter', @_onSerializedFilterChange
    do @_updateUrlParamsModel

  createInstance: ->
    componentClass = @get 'componentClass'
    instance = new componentClass @_getInstanceArguments()
    instance.$el.addClass @get('componentClassName')
    @set 'instance', instance

  renderInstance: ->
    instance = @get 'instance'
    unless instance then return
    unless instance.render
      throw @ERROR.MISSING_RENDER_METHOD @get('id')

    if instance.preRender? and _.isFunction(instance.preRender)
      do instance.preRender

    do instance.render

    if instance.postRender? and _.isFunction(instance.postRender)
      do instance.postRender

  addInstanceInOrder: ->
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

    isAttached = @isAttached()

    if isAttached
      if instance.onAddedToDom? and _.isFunction(instance.onAddedToDom)
        do instance.onAddedToDom

    return isAttached

  isAttached: ->
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

  isTargetPopulated: ->
    $target = @get 'target'
    return $target.children().length > 0

  updateTargetPopulatedState: ->
    $target = @get 'target'
    targetPrefix = @get 'targetPrefix'
    return $target.toggleClass "#{targetPrefix}--has-components", @isTargetPopulated()

  tryToReAddStraysToDom: ->
    if not @isAttached()
      isAttached = do @addInstanceInOrder
      if isAttached
        instance = @get 'instance'
        if instance?.delegateEvents and _.isFunction(instance?.delegateEvents)
          do instance.delegateEvents
      else
        do @disposeInstance

      do @updateTargetPopulatedState

  dispose: ->
    do @disposeInstance
    do @updateTargetPopulatedState
    do @off
    do @clear

  disposeInstance: ->
    instance = @get 'instance'
    if instance?.dispose?
      do instance.dispose
    instance = undefined
    @set
      'instance': undefined
    , silent: true

  _getInstanceArguments: ->
    args = @get('instanceArguments') or {}
    args.urlParams = @get 'urlParams'
    args.urlParamsModel = @get 'urlParamsModel'
    return args

  _previousElement: ($el, order = 0) ->
    if $el.length > 0
      if $el.data('order') < order
        return $el
      else
        @_previousElement $el.prev(), order

  _updateUrlParamsModel: ->
    urlParams = @get 'urlParams'
    urlParamsModel = @get 'urlParamsModel'

    # a properly setup instanceDefinition should never have multiple urlPatterns that matches
    # one and the same url, ex: the url foo/bar/baz would match both patterns
    # ["foo/:section/:id", "foo/*splat"] the correct way would be to select one of them
    # (probably the first) and then use the url property of the params if more parts of the
    # url are needed.
    # To keep it simple we only update the urlParamsModel with the first matchingUrlParams
    # the entire array of matchingUrlParams is passed as an argument to the instance though.

    if urlParams?.length > 0
      urlParamsModel.set urlParams[0]

  _onInstanceChange: ->
    do @renderInstance
    do @addInstanceInOrder
    do @updateTargetPopulatedState

  _onUrlParamsChange: ->
    do @_updateUrlParamsModel

  _onOrderChange: ->
    do @addInstanceInOrder

  _onTargetChange: ->
    do @addInstanceInOrder

  _onSerializedFilterChange: ->
    if @get('reInstantiate')
      do @disposeInstance
      do @createInstance

  _onAdd: ->
    do @createInstance

  _onRemove: ->
    do @dispose