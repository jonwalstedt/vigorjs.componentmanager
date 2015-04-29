class CreateComponentView extends BaseFormView

  className: 'vigorjs-controls__create-component'
  $createForm: undefined

  events:
    'change .vigorjs-controls__targets': '_onTargetChange'
    'click .vigorjs-controls__create-btn': '_onCreateBtnClick'
    'click .vigorjs-controls__add-row': '_onAddRow'
    'click .vigorjs-controls__remove-row': '_onRemoveRow'

  initialize: (attributes) ->
    super
    @listenTo @componentManager, 'component-add component-change component-remove', @_onComponentDefinitionChange

  render: ->
    @$el.html templateHelper.getCreateTemplate()
    @$targets = $ '.vigorjs-controls__targets', @el
    @$createForm = $ '.vigorjs-controls__create', @el
    return @

  _createComponent: ->
    instanceDefinition = @parseForm @$createForm

    console.log 'instanceDefinition: ', instanceDefinition
    try
      @componentManager.addInstance instanceDefinition
      @trigger 'feedback', 'Component instantiated'
    catch error
      @trigger 'feedback', error

  _deselectTargets: ->
    $oldTargets = $ '.component-area--selected'
    $oldTargets.removeClass 'component-area--selected'

  _onComponentDefinitionChange: =>
    do @render

  _onTargetChange: (event) =>
    $option = $ event.currentTarget
    do @_deselectTargets
    $target = $ ".#{@$targets.val()}"
    $target.addClass 'component-area--selected'

  _onCreateBtnClick: (event) ->
    do @_deselectTargets
    do @_createComponent
