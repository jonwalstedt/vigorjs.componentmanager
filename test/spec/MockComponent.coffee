class MockComponent

  $el: undefined
  attr: undefined

  constructor: (attr) ->
    @attr = attr
    @$el = $ '<div clas="mock-component"></div>'
    if @attr?.id
      @$el.attr 'id', @attr?.id

  delegateEvents: ->
    eventsDelegated = true
    return eventsDelegated

  render: ->
    return @

  onAddedToDom: ->
    return @

  receiveMessage: (message) ->
    return @

module.exports = MockComponent