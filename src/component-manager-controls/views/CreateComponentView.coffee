class CreateComponentView extends Backbone.View

  className: 'vigorjs-controls__create-component'
  events:
    'change .vigorjs-controls__targets': '_onTargetChange'
    'click .vigorjs-controls__create-btn': '_onCreateBtnClick'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager
    @listenTo @componentManager, 'component-add component-change component-remove', @_onComponentDefinitionChange

  render: ->
    do @$el.empty
    @$el.html templateHelper.getCreateTemplate()
    @$feedback = $ '.vigorjs-controls__create-feedback', @el
    @$targets = $ '.vigorjs-controls__targets', @el
    return @

  _createComponent: ->
    $createForm = $ '.vigorjs-controls__create', @el
    objs = $createForm.serializeArray()
    console.log objs

  _deselectTargets: ->
    $oldTargets = $ '.component-area--selected'
    $oldTargets.removeClass 'component-area--selected'

  _onComponentDefinitionChange: =>
    do @render

  _onTargetChange: (event) =>
    $option = $ event.currentTarget
    do @_deselectTargets
    $target = $ @$targets.val()
    $target.addClass 'component-area--selected'

  _onCreateBtnClick: (event) ->
    do @_deselectTargets
    do @_createComponent
