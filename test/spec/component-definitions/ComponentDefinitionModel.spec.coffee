assert = require 'assert'
jsdom = require 'jsdom'

componentManager = require('../../../dist/backbone.vigor.componentmanager').componentManager
ComponentDefinitionModel = componentManager.__testOnly.ComponentDefinitionModel
IframeComponent = componentManager.__testOnly.IframeComponent

class DummyComponent
  $el: undefined
  el: undefined
  render: ->
    @$el = $('<div class="dummy-component"></div>')
    @el = @$el.get(0)
    return @

describe 'ComponentDefinitionModel', ->

  describe 'validate', ->
    attrs = undefined
    options= undefined

    beforeEach ->
      attrs = {}
      options = {}

    it 'should throw an error if attrs.id is undefined', ->
      model = new ComponentDefinitionModel()
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id cant be undefined/


    it 'should throw an error if attrs.id is not a string', ->
      model = new ComponentDefinitionModel()
      attrs.id = 123
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id should be a string/

    it 'should throw an error if attrs.id is an empty string', ->
      model = new ComponentDefinitionModel()
      attrs.id = ' '
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id can not be an empty string/

    it 'should throw an error if attrs.src is undefined', ->
      model = new ComponentDefinitionModel()
      attrs.id = 'test'
      attrs.src = undefined
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /src cant be undefined/

    it 'should throw an error if attrs.src is not a string or a constructor function', ->
      model = new ComponentDefinitionModel()
      attrs.id = 'test'
      attrs.src = 123
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /src should be a string or a constructor function/

      model = new ComponentDefinitionModel()
      attrs.id = 'test'
      attrs.src = 'window.app.test'
      errorFn = -> model.validate attrs, options
      assert.doesNotThrow (-> errorFn()), /src should be a string or a constructor function/

      model = new ComponentDefinitionModel()
      attrs.id = 'test'
      attrs.src = DummyComponent
      errorFn = -> model.validate attrs, options
      assert.doesNotThrow (-> errorFn()), /src should be a string or a constructor function/

    it 'should throw an error if attrs.src is an empty string', ->
      model = new ComponentDefinitionModel()
      attrs.id = 'test'
      attrs.src = ' '
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /src can not be an empty string/


  describe 'getClass', ->
    it 'should return the IframeComponent class if src is a url', ->
      dummyComponentDefinitionObj =
        id: 'dummy'
        src: 'http://www.google.com'

      model = new ComponentDefinitionModel(dummyComponentDefinitionObj)
      klass = model.getClass()

      assert.equal klass, IframeComponent

    it 'should should try to find the class on window if src is string but not a url', ->
      window.app = {}
      window.app.test = {}
      window.app.test.DummyComponent = DummyComponent

      dummyComponentDefinitionObj =
        id: 'dummy'
        src: 'app.test.DummyComponent'

      model = new ComponentDefinitionModel(dummyComponentDefinitionObj)
      klass = model.getClass()

      assert.equal klass, DummyComponent

    it 'should return src constructor function if set', ->

      dummyComponentDefinitionObj =
        id: 'dummy'
        src: DummyComponent

      model = new ComponentDefinitionModel(dummyComponentDefinitionObj)
      klass = model.getClass()

      assert.equal klass, DummyComponent

    it 'should throw an error if no class is found', ->
      dummyComponentDefinitionObj =
        id: 'dummy'
        src: 'app.test.TummyComponent'

      model = new ComponentDefinitionModel(dummyComponentDefinitionObj)

      errorFn = -> model.getClass()
      assert.throws (-> errorFn()), /No constructor function found for app.test.TummyComponent/

  describe '_isUrl', ->
    it 'should return true if string is url', ->
      model = new ComponentDefinitionModel()
      assert.equal model._isUrl('http://www.google.com'), true
      assert.equal model._isUrl('http://google.com'), true
      assert.equal model._isUrl('https://google.com'), true
      assert.equal model._isUrl('http://127.0.0.1:8079/'), true

    it 'should return false if string is not url', ->
      model = new ComponentDefinitionModel()
      assert.equal model._isUrl('test'), false
      assert.equal model._isUrl('http//google.com'), false
      assert.equal model._isUrl('/google'), false
      assert.equal model._isUrl('127.0.1:8079'), false
