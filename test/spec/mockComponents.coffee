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

class MockComponent2
  $el: undefined
  attr: undefined
  constructor: (attr) ->
    @attr = attr
    @$el = $ '<div clas="mock-component2"></div>'

  render: ->
    return @

module.exports =
  MockComponent: MockComponent
  MockComponent2: MockComponent2
