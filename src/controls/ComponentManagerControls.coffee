class ComponentManagerControls extends Backbone.View

  className: 'vigorjs-controls vigorjs-controls--active'
  events:
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'
    'click .vigorjs-controls__add-row': '_onAddRow'
    'click .vigorjs-controls__register-btn': '_onRegister'

  initialize: ->
    console.log 'ComponentManagerControls:initialize'

  render: ->
    do @$el.empty
    @$el.html @getTemplate()
    return @

  getTemplate: ->
    availableComponents = Vigor.componentManager.componentDefinitionsCollection.toJSON()
    markup = """
    <button class='vigorjs-controls__toggle-controls'>Controls</button>

    <div class='vigorjs-controls__step vigorjs-controls__select--step-one'>
      <h1 class='vigorjs-controls__header'>Do you want to register, create, update or delete a component?</h1>
      <button class='vigorjs-controls__show-register-btn'>Register an iframe component</button>
      <button class='vigorjs-controls__show-create-btn'>Create</button>
      <button class='vigorjs-controls__show-update-btn'>Update</button>
      <button class='vigorjs-controls__show-delete-btn'>Delete</button>
    </div>

    <div class='vigorjs-controls__step vigorjs-controls__select--step-two'>
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
          <div class="vigorjs-controls__args-row">
            <input type='text' placeholder='Key' name='key' class='vigorjs-controls__args-key'/>
            <input type='text' placeholder='Value' name='value' class='vigorjs-controls__args-val'/>
          </div>
          <button type='button' class='vigorjs-controls__add-row'>add row</button>
        </div>

        <button type='button' class='vigorjs-controls__register-btn'>Register</button>
      </form>
      <div class='vigorjs-controls__step vigorjs-controls__create'></div>
      <div class='vigorjs-controls__step vigorjs-controls__update'></div>
      <div class='vigorjs-controls__step vigorjs-controls__delete'></div>
    </div>

    """
    return markup

  _onToggleControlsClick: ->
    @$el.toggleClass 'vigorjs-controls--active'

  _onAddRow: (event) ->
    $btn = $ event.currentTarget
    $lastRow = $btn.parent().find('.vigorjs-controls__args-row:last')
    $newRow = $lastRow.clone()
    $newRow.find('input').val('')
    $newRow.insertAfter $lastRow

  _onRegister: ->
    $registerForm = $ '.vigorjs-controls__register', @el
    $argRows = $registerForm.find '.vigorjs-controls__args-row'
    componentDefinition = {}
    componentDefinition.args = {}
    objs = $registerForm.serializeArray()

    for row in $argRows
      $row = $ row
      key = $row.find('.vigorjs-controls__args-key').val()
      unless key or if key is ''
        then return
      componentDefinition.args[key] = $row.find('.vigorjs-controls__args-val').val()

    console.log componentDefinition, objs
    componentDefinition = {
      componentId: objs.componentId
      src: objs.src
      showcount: objs.showcount
    }
    console.log componentDefinition



Vigor.ComponentManagerControls = ComponentManagerControls
