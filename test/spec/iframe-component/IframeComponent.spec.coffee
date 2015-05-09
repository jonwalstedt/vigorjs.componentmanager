assert = require 'assert'
jsdom = require 'jsdom'

componentManager = require('../../../dist/backbone.vigor.componentmanager').componentManager
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

      assert.equal iframeComponent.el.src, 'http://www.google.com'

    it 'should add on load listener', ->

