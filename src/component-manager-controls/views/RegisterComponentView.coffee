class RegisterComponentView extends BaseFormView

  className: 'vigorjs-controls__register-component'

  $registerForm: undefined

  events:
    'change .vigorjs-controls__component-id': '_onComponentChange'
    'click .vigorjs-controls__register-btn': '_onRegister'
    'click .vigorjs-controls__add-row': '_onAddRow'
    'click .vigorjs-controls__remove-row': '_onRemoveRow'

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  render: (selectedComponent) ->
    @$el.html templateHelper.getRegisterTemplate(selectedComponent)
    @$registerForm = $ '.vigorjs-controls__register', @el
    @$componentsDropdown = $ '.vigorjs-controls__component-id', @el
    return @

  _registerComponent: ->
    componentDefinition = @parseForm @$registerForm

    try
      @componentManager.addComponent componentDefinition
      @$registerForm.find('input').val('')
      @trigger 'feedback', 'Component registered'
      setTimeout =>
        @trigger 'show', 'create'
      , 1000
    catch error
      @trigger 'feedback', error

  _onComponentChange: =>
    componentId = @$componentsDropdown.val()
    unless componentId is 'none-selceted'
      selectedComponent = @componentManager.getComponentById componentId
      @render selectedComponent

  _onRegister: =>
    do @_registerComponent
