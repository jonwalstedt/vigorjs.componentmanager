class BaseFormView extends Backbone.View
  componentManager: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager

  parseForm: ($form) ->
    objs = $form.serializeArray()
    definition = {}
    definition.args = {}
    args = []

    for obj, i in objs
      if obj.name isnt 'key' and obj.name isnt 'value'
        definition[obj.name] = obj.value
      else
        args.push obj

    for arg, i in args
      if i % 2
        definition.args[args[i-1].value] = args[i].value

    return definition

  _onAddRow: (event) ->
    console.log '_onAddRow'
    $btn = $ event.currentTarget
    $rows = $ '.vigorjs-controls__rows', @el
    $newRow = $ templateHelper.getArgsRow()
    $rows.append $newRow

  _onRemoveRow: (event) ->
    $btn = $ event.currentTarget
    do $btn.parent().find('.vigorjs-controls__args-row:last').remove

