assert = require 'assert'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
InstanceDefinitionsCollection = componentManager.__testOnly.InstanceDefinitionsCollection

describe 'InstanceDefinitionsCollection', ->
  describe 'setTargetPrefix', ->
    it 'should store passed prefix on the instance', ->
      instanceDefinitionsCollection = new InstanceDefinitionsCollection()
      instanceDefinitionsCollection.setTargetPrefix 'my-prefix'
      assert.equal instanceDefinitionsCollection.targetPrefix, 'my-prefix'

  describe 'parse', ->

  describe 'parseInstanceDefinition', ->

  describe 'getInstanceDefinitions', ->

  describe 'getInstanceDefinitionsByUrl', ->

  describe 'filterInstanceDefinitionsByUrl', ->

  describe 'filterInstanceDefinitionsByString', ->

  describe 'filterInstanceDefinitionsByConditions', ->

  describe 'addUrlParams', ->