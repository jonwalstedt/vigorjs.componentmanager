class IframeComponent extends Backbone.View

  tagName: 'iframe'
  className: 'vigor-component--iframe'
  attributes:
    seamless: 'seamless'
    scrolling: no
    border: 0
    frameborder: 0

  src: undefined
  targetOrigin: 'http://localhost:7070'

  constructor: (attrs) ->
    _.extend @attributes, attrs?.iframeAttributes

    if attrs?.targetOrigin
      @targetOrigin = attrs.targetOrigin

    super

  initialize: (attrs) ->
    do @addListeners
    if attrs?.src?
      @src = attrs.src
    super

  addListeners: ->
    @$el.on 'load', @onIframeLoaded

  removeListeners: ->
    @$el.off 'load', @onIframeLoaded

  render: ->
    @$el.attr 'src', @src
    return @

  dispose: ->
    do @removeListeners
    do @remove

  postMessageToIframe: (message) ->
    iframeWin = @$el.get(0).contentWindow
    iframeWin.postMessage message, @targetOrigin

  # Default implementation is a noop.
  receiveMessage: (message) ->

  # Default implementation is a noop.
  onIframeLoaded: (event) =>

Vigor.IframeComponent = IframeComponent