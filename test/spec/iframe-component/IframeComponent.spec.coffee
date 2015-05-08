assert = require 'assert'
jsdom = require 'jsdom'

componentManager = require('../../../dist/backbone.vigor.componentmanager').componentManager
IframeComponent = componentManager.__testOnly.IframeComponent

describe 'IframeComponent', ->
  it 'it should add attributes to the iframe from passed "iframeAttributes" object', ->
    attrs =
      iframeAttributes:
        width: 400
        height: 400

    iframeComponent = new IframeComponent attrs
    assert.equal iframeComponent.el.width, 400
    assert.equal iframeComponent.el.height, 400


