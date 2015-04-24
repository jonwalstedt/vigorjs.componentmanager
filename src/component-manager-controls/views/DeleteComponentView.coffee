class DeleteComponentView extends Backbone.View

  className: 'vigorjs-controls__delete-component'
  # events:
  #   'click .vigorjs-controls__register-btn': '_onRegister'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  render: ->
    do @$el.empty
    @$el.html @getTemplate()
    @$feedback = $ '.vigorjs-controls__deltete-feedback', @el
    return @

  getTemplate: ->
    markup = """
      <form class='vigorjs-controls__delete'>
        <div class='vigorjs-controls__delete-feedback'></div>
        <button type='button' class='vigorjs-controls__delete-btn'>Delete</button>
      </form>
    """
    return markup
