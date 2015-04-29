class RegisterComponentView extends BaseFormView

  className: 'vigorjs-controls__register-component'

  $registerForm: undefined

  events:
    'click .vigorjs-controls__register-btn': '_onRegister'

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  render: ->
    @$el.html templateHelper.getRegisterTemplate()
    @$registerForm = $ '.vigorjs-controls__register', @el
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

  _onRegister: =>
    do @_registerComponent
