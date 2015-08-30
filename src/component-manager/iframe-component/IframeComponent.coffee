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
    super

  initialize: (attrs) ->
    if attrs?.src?
      @src = attrs.src

    do @addListeners

  addListeners: ->
    @$el.on 'load', @onIframeLoaded

  removeListeners: ->
    @$el.off 'load', @onIframeLoaded

  render: ->
    @$el.attr 'src', @src

  dispose: ->
    @$el.off 'load', @onIframeLoaded
    do @remove

  receiveMessage: (message) ->

  postMessageToIframe: (message) ->
    iframeWin = @$el.get(0).contentWindow
    iframeWin.postMessage message, @targetOrigin

  onIframeLoaded: (event) =>

  onMessageReceived: (event) =>
    console.log 'instance should handle incomming message', event.data

Vigor.IframeComponent = IframeComponent