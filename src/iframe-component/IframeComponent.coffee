class IframeComponent extends Backbone.View

  tagName: 'iframe'
  className: 'vigor-component--iframe'
  attributes:
    seamless: 'seamless'
    scrolling: no

  src: undefined

  initialize: (attrs) ->
    @src = attrs.src
    @$el.on 'load', @onIframeLoaded

  render: ->
    @$el.attr 'src', @src

  dispose: ->
    @$el.off 'load', @onIframeLoaded
    do @remove

  onIframeLoaded: (event) ->
