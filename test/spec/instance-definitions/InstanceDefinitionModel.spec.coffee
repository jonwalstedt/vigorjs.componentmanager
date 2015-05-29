assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'

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


  describe 'isAttached', ->
    it 'should return false if element is not present in the DOM', ->
      $instanceEl = $('<div/>')
      instance =
        $el: $instanceEl

      instanceDefinitionModel.set 'instance', instance
      isAttached = instanceDefinitionModel.isAttached()
      assert.equal isAttached, false

    it 'should return true if element is present in the DOM', ->
      $instanceEl = $('<div/>').addClass('test')
      instance =
        $el: $instanceEl

      $('body').append instance.$el

      instanceDefinitionModel.set 'instance', instance
      isAttached = instanceDefinitionModel.isAttached()
      assert.equal isAttached, true


  describe 'incrementShowCount', ->
    it 'should increment the showCount and update the model', ->
      assert.equal instanceDefinitionModel.get('showCount'), 0
      instanceDefinitionModel.incrementShowCount()
      assert.equal instanceDefinitionModel.get('showCount'), 1

  describe 'renderInstance', ->
    it 'should call preRender if it exsists', ->
      instance =
        preRender: sinon.spy()
        render: ->

      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.renderInstance()
      assert instance.preRender.called

    it 'should not throw an error if preRender doesnt exsists', ->
      instance =
        render: ->

      instanceDefinitionModel.set 'instance', instance
      assert.doesNotThrow -> instanceDefinitionModel.renderInstance()

    it 'should call render if it exsists', ->
      instance =
        render: sinon.spy()

      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.renderInstance()
      assert instance.render.called

    it 'should throw an missing render method error if there are no render method on the instance', ->
      instance =
        id: 'test'
        preRender: ->
        get: (key) ->
          if key is 'id'
            return 'test'

      instanceDefinitionModel.set 'instance', instance
      errorFn = -> instanceDefinitionModel.renderInstance()

      assert.throws (-> errorFn()), /The instance test does not have a render method/

    it 'should call postRender if it exsists', ->
      instance =
        id: 'test'
        render: ->
        postRender: sinon.spy()

      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.renderInstance()
      assert instance.postRender.called

    it 'should not throw an error if postRender doesnt exsists', ->
      instance =
        render: ->

      instanceDefinitionModel.set 'instance', instance
      assert.doesNotThrow -> instanceDefinitionModel.renderInstance()

  describe 'dispose', ->
    it 'should call instance.dispose', ->
      instance =
        render: ->
        dispose: sinon.spy()

      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.dispose()

      assert instance.dispose.called

    it 'should call clear', ->
      instance =
        render: ->
        dispose: ->

      sinon.spy instanceDefinitionModel, 'clear'
      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.dispose()

      assert instanceDefinitionModel.clear.called

  describe 'disposeInstance', ->
  describe 'exceedsMaximumShowCount', ->
  describe 'passesFilter', ->
  describe 'hasToMatchString', ->
  describe 'cantMatchString', ->
  describe 'includeIfStringMatches', ->
  describe 'doesUrlPatternMatch', ->
  describe 'addUrlParams', ->
