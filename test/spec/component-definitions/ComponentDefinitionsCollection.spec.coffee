assert = require 'assert'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
ComponentDefinitionsCollection = componentManager.__testOnly.ComponentDefinitionsCollection

describe 'ComponentDefinitionsCollection', ->
  it 'is a regular Backbone.Collection without additional logic at the moment - no tests so far', ->
