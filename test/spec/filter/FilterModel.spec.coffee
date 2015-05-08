assert = require 'assert'
jsdom = require 'jsdom'

componentManager = require('../../../dist/backbone.vigor.componentmanager').componentManager
FilterModel = componentManager.__testOnly.FilterModel

describe 'FilterModel', ->
  it 'is a regular Backbone.Model without additional logic at the moment - no tests so far', ->
