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
    @$el.html @getTemplate()
    @$feedback = $ '.vigorjs-controls__register-feedback', @el
    return @

  getTemplate: ->
    availableComponents = @componentManager.componentDefinitionsCollection.toJSON()

    markup = """
      <form class='vigorjs-controls__register'>
        <div class="vigorjs-controls__field">
          <label for='component-id'>Unique Component Id</label>
          <input type='text' id='component-id' placeholder='Unique Component Id' name='componentId'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-src'>Component Source - url or namespaced path to view</label>
          <input type='text' id='component-src' placeholder='Src' name='src'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-max-showcount'>Component Showcount - Specify if the component should have a maximum instantiation count ex. 1 if it should only be created once per session</label>
          <input type='text' id='component-max-showcount' placeholder='Max Showcount' name='maxShowCount'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-args'>Component arguments (key:value pairs)</label>
          <div class="vigorjs-controls__rows">
            #{@getRow()}
          </div>
          <button type='button' class='vigorjs-controls__remove-row'>remove row</button>
          <button type='button' class='vigorjs-controls__add-row'>add row</button>
        </div>

        <div class='vigorjs-controls__register-feedback'></div>
        <button type='button' class='vigorjs-controls__register-btn'>Register</button>
      </form>
    """
    return markup

  getRow: ->
    markup = """
      <div class="vigorjs-controls__args-row">
        <input type='text' placeholder='Key' name='key' class='vigorjs-controls__args-key'/>
        <input type='text' placeholder='Value' name='value' class='vigorjs-controls__args-val'/>
      </div>
    """
    return markup

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
      @componentManager.addComponentDefinition componentDefinition
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
    $newRow = $ @getRow()
    $rows.append $newRow

  _onRemoveRow: (event) ->
    $btn = $ event.currentTarget
    do $btn.parent().find('.vigorjs-controls__args-row:last').remove

  _onRegister: =>
    do @_registerComponent
