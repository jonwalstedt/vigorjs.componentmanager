assert = require 'assert'
jsdom = require 'jsdom'

componentManager = require('../../../dist/backbone.vigor.componentmanager').componentManager
ComponentDefinitionsCollection = componentManager.__testOnly.ComponentDefinitionsCollection

describe 'ComponentDefinitionsCollection', ->
  it 'is a regular Backbone.Collection without additional logic at the moment - no tests so far', ->
