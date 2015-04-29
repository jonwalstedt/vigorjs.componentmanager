class UpdateComponentView extends BaseFormView

  className: 'vigorjs-controls__update-component'
  # events:
  #   'click .vigorjs-controls__register-btn': '_onRegister'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  render: ->
    do @$el.empty
    @$el.html @getTemplate()
    @$feedback = $ '.vigorjs-controls__update-feedback', @el
    return @

  getTemplate: ->
    markup = """
      <form class='vigorjs-controls__update'>
        <div class='vigorjs-controls__update-feedback'></div>
        <button type='button' class='vigorjs-controls__update-btn'>Create</button>
      </form>
    """
    return markup
