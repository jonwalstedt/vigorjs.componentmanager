class ComponentManagerControls extends Backbone.View

  className: 'vigorjs-controls vigorjs-controls--active'
  events:
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'

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
      <button class='vigorjs-controls__register'>Register an iframe component</button>
      <button class='vigorjs-controls__create'>Create</button>
      <button class='vigorjs-controls__update'>Update</button>
      <button class='vigorjs-controls__delete'>Delete</button>
    </div>

    <div class='vigorjs-controls__step vigorjs-controls__select--step-two'>
      <div class='vigorjs-controls__step vigorjs-controls__create'>

      </div>
      <div class='vigorjs-controls__step vigorjs-controls__update'>
      </div>
      <div class='vigorjs-controls__step vigorjs-controls__delete'>
      </div>
    </div>

    """
    return markup

  _onToggleControlsClick: ->
    @$el.toggleClass 'vigorjs-controls--active'

Vigor.ComponentManagerControls = ComponentManagerControls
