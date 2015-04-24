class ComponentManagerControls extends Backbone.View

  className: 'vigorjs-controls vigorjs-controls--active'
  events:
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'
    'click .vigorjs-controls__show-form-btn': '_onShowFormBtnClick'

  componentManager: undefined
  registerComponent: undefined
  $formWrapper: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager
    templateHelper.storeComponentManager @componentManager

  render: ->
    do @$el.empty
    @$el.html @getTemplate()

    @$wrappers = $ '.vigorjs-controls__wrapper', @el
    @$registerWrapper = $ '.vigorjs-controls__register-wrapper', @el
    @$createWrapper = $ '.vigorjs-controls__create-wrapper', @el
    @$updateWrapper = $ '.vigorjs-controls__update-wrapper', @el
    @$deleteWrapper = $ '.vigorjs-controls__delete-wrapper', @el

    do @_addRegisterForm
    do @_addCreateForm
    do @_addUpdateForm
    do @_addDeleteForm
    return @

  getTemplate: ->
    availableComponents = Vigor.componentManager.componentDefinitionsCollection.toJSON()
    markup = """
    <button class='vigorjs-controls__toggle-controls'>Controls</button>

    <div class='vigorjs-controls__step'>
      <h1 class='vigorjs-controls__header'>Do you want to register, create, update or delete a component?</h1>
      <button class='vigorjs-controls__show-form-btn' data-target='register'>Register</button>
      <button class='vigorjs-controls__show-form-btn' data-target='create'>Create</button>
      <button class='vigorjs-controls__show-form-btn' data-target='update'>Update</button>
      <button class='vigorjs-controls__show-form-btn' data-target='delete'>Delete</button>
    </div>

    <div class='vigorjs-controls__forms'>
      <div class='vigorjs-controls__wrapper vigorjs-controls__register-wrapper' data-id='register'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__create-wrapper' data-id='create'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__update-wrapper' data-id='update'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__delete-wrapper' data-id='delete'></div>
    </div>

    """
    return markup

  _addRegisterForm: ->
    @registerComponent = new RegisterComponentView({componentManager: @componentManager})
    @registerComponent.on 'show', @_onShow
    @$registerWrapper.html @registerComponent.render().$el

  _addCreateForm: ->
    @createComponent = new CreateComponentView({componentManager: @componentManager})
    @createComponent.on 'show', @_onShow
    @$createWrapper.html @createComponent.render().$el

  _addUpdateForm: ->
    @updateComponent = new UpdateComponentView({componentManager: @componentManager})
    @updateComponent.on 'show', @_onShow
    @$updateWrapper.html @updateComponent.render().$el

  _addDeleteForm: ->
    @deleteComponent = new DeleteComponentView({componentManager: @componentManager})
    @deleteComponent.on 'show', @_onShow
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

Vigor.ComponentManagerControls = ComponentManagerControls
