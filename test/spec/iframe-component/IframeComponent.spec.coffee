assert = require 'assert'
sinon = require 'sinon'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
IframeComponent = componentManager.__testOnly.IframeComponent

describe 'IframeComponent', ->
  describe 'constructor', ->
    it 'should add attributes to the iframe from passed "iframeAttributes" object', ->
      attrs =
        iframeAttributes:
          width: 400
          height: 400

      iframeComponent = new IframeComponent attrs
      assert.equal iframeComponent.el.width, 400
      assert.equal iframeComponent.el.height, 400

    it 'should keep default attributes unless overridden', ->
      attrs =
        iframeAttributes:
          width: 400
          height: 400

      iframeComponent = new IframeComponent attrs

      assert.equal iframeComponent.el.attributes[0].name, 'seamless'
      assert.equal iframeComponent.el.attributes[0].nodeValue, 'seamless'
      assert.equal iframeComponent.el.attributes[1].name, 'scrolling'
      assert.equal iframeComponent.el.attributes[1].nodeValue, 'false'
      assert.equal iframeComponent.el.attributes[2].name, 'border'
      assert.equal iframeComponent.el.attributes[2].nodeValue, 0
      assert.equal iframeComponent.el.attributes[3].name, 'frameborder'
      assert.equal iframeComponent.el.attributes[3].nodeValue, 0

      attrs =
        iframeAttributes:
          width: 400
          height: 400
          scrolling: true
          frameborder: 1

      iframeComponent = new IframeComponent attrs

      assert.equal iframeComponent.el.attributes[0].name, 'seamless'
      assert.equal iframeComponent.el.attributes[0].nodeValue, 'seamless'
      assert.equal iframeComponent.el.attributes[1].name, 'scrolling'
      assert.equal iframeComponent.el.attributes[1].nodeValue, 'true'
      assert.equal iframeComponent.el.attributes[2].name, 'border'
      assert.equal iframeComponent.el.attributes[2].nodeValue, 0
      assert.equal iframeComponent.el.attributes[3].name, 'frameborder'
      assert.equal iframeComponent.el.attributes[3].nodeValue, 1


  describe 'initialize', ->
    it 'should set src attribute if passed', ->

      iframeComponent = new IframeComponent()

      attrs =
        src: 'http://www.google.com'

      iframeComponent.initialize attrs

      assert.equal iframeComponent.src, 'http://www.google.com'

    it 'should add load listener', ->

      iframeComponent = new IframeComponent()
      listener = sinon.spy iframeComponent.$el, 'on'
      do iframeComponent.initialize

      assert listener.calledWith 'load', iframeComponent.onIframeLoaded

  describe 'render', ->
    it 'should add src attribute to el', ->
      iframeComponent = new IframeComponent()

      attrs =
        src: 'http://www.google.com'

      iframeComponent.initialize attrs
      do iframeComponent.render

      assert.equal iframeComponent.el.src, 'http://www.google.com'

  describe 'dispose', ->
    it 'shuld remove load listener and call this.remove', ->

      iframeComponent = new IframeComponent()
      listener = sinon.spy iframeComponent.$el, 'off'
      remove = sinon.spy iframeComponent, 'remove'
      do iframeComponent.dispose

      assert listener.calledWith 'load', iframeComponent.onIframeLoaded
      assert listener.called

  describe 'onIframeLoaded', ->
    it 'should be called after iframe content has been loaded, no tests yet..', ->
