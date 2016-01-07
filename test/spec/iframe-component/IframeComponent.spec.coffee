assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigorjs.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

IframeComponent = __testOnly.IframeComponent

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

    it 'should call addListeners', ->
      iframeComponent = new IframeComponent()
      addListenersSpy = sinon.spy iframeComponent, 'addListeners'
      do iframeComponent.initialize
      assert addListenersSpy.called

  describe 'addListeners', ->
    it 'should add an on load listener by calling the "on" method with the
    correct arguments', ->
      iframeComponent = new IframeComponent()
      listener = sinon.spy iframeComponent.$el, 'on'
      do iframeComponent.addListeners

      assert listener.calledWith 'load', iframeComponent.onIframeLoaded

  describe 'removeListeners', ->
    it 'should remove the on load listener by calling off and passing theh
    correct arguments', ->
      iframeComponent = new IframeComponent()
      listener = sinon.spy iframeComponent.$el, 'off'
      do iframeComponent.removeListeners

      assert listener.calledWith 'load', iframeComponent.onIframeLoaded

  describe 'render', ->
    it 'should add src attribute to el', ->
      iframeComponent = new IframeComponent()

      attrs =
        src: 'http://www.google.com'

      iframeComponent.initialize attrs
      assert.equal iframeComponent.el.src, ''

      do iframeComponent.render
      assert.equal iframeComponent.el.src, 'http://www.google.com'

  describe 'dispose', ->
    it 'should call remove', ->
      iframeComponent = new IframeComponent()
      removeSpy = sinon.spy iframeComponent, 'remove'
      do iframeComponent.dispose
      assert removeSpy.called

    it 'should call removeListeners', ->
      iframeComponent = new IframeComponent()
      listenerSpy = sinon.spy iframeComponent.$el, 'off'
      do iframeComponent.dispose
      assert listenerSpy.called

  describe 'postMessageToIframe', ->
    it 'should call postMessage with the passed message and the targetOrigin', ->
      iframeComponent = new IframeComponent()
      contentWindow = iframeComponent.$el.get(0).contentWindow
      postMessageSpy = contentWindow.postMessage = sinon.stub()
      message = 'dummy message'
      iframeComponent.postMessageToIframe message, iframeComponent.targetOrigin
      assert postMessageSpy.calledWith message, iframeComponent.targetOrigin

  # Default implementation is a noop.
  describe 'receiveMessage', ->
    it 'the default implementation does nothing but is called by
    componentLoader.postMessageToInstance', ->

  # Default implementation is a noop.
  describe 'onIframeLoaded', ->
    it 'should be called after iframe content has been loaded (when the load
      event is triggered)', ->
      onIframeLoadedSpy = sinon.spy IframeComponent.prototype, 'onIframeLoaded'
      iframeComponent = new IframeComponent()
      iframeComponent.$el.trigger 'load'
      assert onIframeLoadedSpy.calledOnce

