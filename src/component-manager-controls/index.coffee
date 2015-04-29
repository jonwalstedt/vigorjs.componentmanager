class ComponentManagerControls extends Backbone.View

  className: 'vigorjs-controls vigorjs-controls--active'
  events:
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'
    'click .vigorjs-controls__show-form-btn': '_onShowFormBtnClick'

  componentManager: undefined

  registerComponent: undefined
  createComponent: undefined
  updateComponent: undefined
  deleteComponent: undefined

  $wrappers: undefined
  $registerWrapper: undefined
  $createWrapper: undefined
  $updateWrapper: undefined
  $deleteWrapper: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager
    templateHelper.storeComponentManager @componentManager
    do @render
    do @_addForms

  render: ->
    do @$el.empty
    @$el.html templateHelper.getMainTemplate()

    @$wrappers = $ '.vigorjs-controls__wrapper', @el
    @$registerWrapper = $ '.vigorjs-controls__register-wrapper', @el
    @$createWrapper = $ '.vigorjs-controls__create-wrapper', @el
    @$updateWrapper = $ '.vigorjs-controls__update-wrapper', @el
    @$deleteWrapper = $ '.vigorjs-controls__delete-wrapper', @el
    @$feedback = $ '.vigorjs-controls__feedback', @el

    return @

  _addForms: ->
    @registerComponent = new RegisterComponentView({componentManager: @componentManager})
    @registerComponent.on 'show', @_onShow
    @registerComponent.on 'feedback', @_onShowFeedback
    @$registerWrapper.html @registerComponent.render().$el

    @createComponent = new CreateComponentView({componentManager: @componentManager})
    @createComponent.on 'show', @_onShow
    @createComponent.on 'feedback', @_onShowFeedback
    @$createWrapper.html @createComponent.render().$el

    @updateComponent = new UpdateComponentView({componentManager: @componentManager})
    @updateComponent.on 'show', @_onShow
    @updateComponent.on 'feedback', @_onShowFeedback
    @$updateWrapper.html @updateComponent.render().$el

    @deleteComponent = new DeleteComponentView({componentManager: @componentManager})
    @deleteComponent.on 'show', @_onShow
    @deleteComponent.on 'feedback', @_onShowFeedback
    @$deleteWrapper.html @deleteComponent.render().$el

  _showWrapper: (targetName) ->
    @$wrappers.removeClass 'vigorjs-controls__wrapper--show'
    $target = @$wrappers.filter("[data-id='#{targetName}']")
    $target.addClass 'vigorjs-controls__wrapper--show'

  _onToggleControlsClick: ->
    @$el.toggleClass 'vigorjs-controls--active'

  _onShowFormBtnClick: (event) =>
    $btn = $ event.currentTarget
    targetName = $btn.data 'target'
    @_showWrapper targetName

  _onShow: (targetName) =>
    @_showWrapper targetName

  _onShowFeedback: (feedback) =>
    @$feedback.html feedback
    setTimeout =>
      do @$feedback.empty
    , 3000

Vigor.ComponentManagerControls = ComponentManagerControls
