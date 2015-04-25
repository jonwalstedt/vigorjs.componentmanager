class CreateComponentView extends Backbone.View

  className: 'vigorjs-controls__create-component'
  # events:
  #   'click .vigorjs-controls__register-btn': '_onRegister'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager
    @listenTo @componentManager.componentDefinitionsCollection, 'change add remove', @_onComponentDefinitionChange

  render: ->
    do @$el.empty
    @$el.html templateHelper.getCreateTemplate()
    @$feedback = $ '.vigorjs-controls__create-feedback', @el
    return @

  _onComponentDefinitionChange: =>
    do @render