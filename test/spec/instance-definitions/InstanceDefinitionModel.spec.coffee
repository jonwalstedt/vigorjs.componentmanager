assert = require 'assert'
sinon = require 'sinon'

componentManager = require('../../../dist/vigor.componentmanager').componentManager
InstanceDefinitionModel = componentManager.__testOnly.InstanceDefinitionModel

describe 'InstanceDefinitionModel', ->

  instanceDefinitionModel = undefined

  beforeEach ->
    instanceDefinitionModel = new InstanceDefinitionModel()

  describe 'validate', ->
    it 'should throw an error if the id is undefined', ->
      attrs =
        order: 10

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /id cant be undefined/

    it 'should throw an error if the id isnt a string', ->
      attrs =
        id: 12
        order: 10

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /id should be a string/

    it 'should throw an error if the id is an empty string', ->
      attrs =
        id: ' '
        order: 10

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /id can not be an empty string/

    it 'should throw an error if the componentId is undefined', ->
      attrs =
        id: 'my-instance-id'
        order: 10

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /componentId cant be undefined/

    it 'should throw an error if the componentId isnt a string', ->
      attrs =
        id: 'my-instance-id'
        order: 10
        componentId: 123

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /componentId should be a string/

    it 'should throw an error if the componentId is an empty string', ->
      attrs =
        id: 'my-instance-id'
        order: 10
        componentId: ' '

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /componentId can not be an empty string/

    it 'should throw an error if the targetName is undefined', ->
      attrs =
        id: 'my-instance-id'
        order: 10
        componentId: 'my-component-id'

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /targetName cant be undefined/


  describe 'incrementShowCount', ->
  describe 'dispose', ->
  describe 'disposeInstance', ->
  describe 'exceedsMaximumShowCount', ->
  describe 'passesFilter', ->
  describe 'hasToMatchString', ->
  describe 'cantMatchString', ->
  describe 'includeIfStringMatches', ->
  describe 'doesUrlPatternMatch', ->
  describe 'addUrlParams', ->
