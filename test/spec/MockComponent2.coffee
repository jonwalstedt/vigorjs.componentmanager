class MockComponent2
  $el: undefined
  attr: undefined
  constructor: (attr) ->
    @attr = attr
    @$el = $ '<div clas="mock-component2"></div>'

  render: ->
    return @

module.exports = MockComponent2