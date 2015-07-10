assert = require 'assert'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

ComponentDefinitionsCollection = __testOnly.ComponentDefinitionsCollection

describe 'ComponentDefinitionsCollection', ->
  it 'is a regular Backbone.Collection without additional logic at the moment - no tests so far', ->
