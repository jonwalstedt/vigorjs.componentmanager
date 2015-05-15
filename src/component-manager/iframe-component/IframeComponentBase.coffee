class IframeComponentBase extends Backbone.View

  tagName: 'iframe'
  className: 'vigor-component--iframe'
  attributes:
    seamless: 'seamless'
    scrolling: no
    border: 0
    frameborder: 0

  src: undefined

  constructor: (attrs) ->
    _.extend @attributes, attrs?.iframeAttributes
    super

  initialize: (attrs) ->
    if attrs?.src?
      @src = attrs.src
    @$el.on 'load', @onIframeLoaded

  render: ->
    @$el.attr 'src', @src

  dispose: ->
    @$el.off 'load', @onIframeLoaded
    do @remove

  onIframeLoaded: (event) ->

Vigor.IframeComponentBase = IframeComponentBase