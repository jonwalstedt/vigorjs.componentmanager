class RegisterComponentView extends Backbone.View

  className: 'vigorjs-controls__register-component'
  events:
    'click .vigorjs-controls__remove-row': '_onRemoveRow'
    'click .vigorjs-controls__add-row': '_onAddRow'
    'click .vigorjs-controls__register-btn': '_onRegister'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  render: ->
    do @$el.empty
    @$el.html templateHelper.getRegisterTemplate()
    @$feedback = $ '.vigorjs-controls__register-feedback', @el
    return @

  _registerComponent: ->
    $registerForm = $ '.vigorjs-controls__register', @el
    $argRows = $registerForm.find '.vigorjs-controls__args-row'
    componentDefinition = {}
    componentDefinition.args = {}
    objs = $registerForm.serializeArray()
    args = []

    for obj, i in objs
      if obj.name isnt 'key' and obj.name isnt 'value'
        componentDefinition[obj.name] = obj.value
      else
        args.push obj

    for arg, i in args
      if i % 2
        componentDefinition.args[args[i-1].value] = args[i].value

    try
      @componentManager.addComponent componentDefinition
      $registerForm.find('input').val('')
      @_showFeedback 'Component registered'
      setTimeout =>
        @trigger 'show', 'create'
      , 1000
    catch error
      @_showFeedback error

  _showFeedback: (feedback) ->
    @$feedback.html feedback

  _onAddRow: (event) ->
    $btn = $ event.currentTarget
    $rows = $ '.vigorjs-controls__rows', @el
    $newRow = $ templateHelper.getArgsRow()
    $rows.append $newRow

  _onRemoveRow: (event) ->
    $btn = $ event.currentTarget
    do $btn.parent().find('.vigorjs-controls__args-row:last').remove

  _onRegister: =>
    do @_registerComponent
