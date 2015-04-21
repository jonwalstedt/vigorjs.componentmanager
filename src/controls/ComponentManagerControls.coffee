class ComponentManagerControls extends Backbone.View

  className: 'vigorjs-controls'
  events:
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'

  initialize: ->
    console.log 'ComponentManagerControls:initialize'

  render: ->
    do @$el.empty
    @$el.append @generateElement(tagName: 'button', name: 'Create component', \
    classes: 'vigorjs-controls__toggle-controls')

    @$el.append @generateElement(tagName: 'select', className: 'test', \
    options: [{text: 'option1', value: 'val1'}, {text: 'option2', value: 'val2'}])

    @$el.append @generateElement(tagName: 'button', name: 'Change component')

    @$el.append @generateElement(tagName: 'button', name: 'Remove component')
    return @

  generateElement: (attrs) ->
    el = document.createElement attrs.tagName
    $el = $ el
    $el.addClass attrs.classes
    if attrs.name
      $el.text attrs.name

    if attrs.tagName is 'select'
      for option in attrs.options
        optionEl = document.createElement 'option'
        $optionEl = $ optionEl
        $optionEl.html option.text
        $optionEl.attr 'value', option.value
        $el.append optionEl

    return $el

  _onToggleControlsClick: ->
    @$el.toggleClass 'vigorjs-controls--active'

Vigor.ComponentManagerControls = ComponentManagerControls
