assert = require 'assert'
sinon = require 'sinon'
Vigor = require '../../../dist/vigor.componentmanager'
MockComponent = require '../MockComponent'

__testOnly = Vigor.ComponentManager.__testOnly

ComponentDefinitionModel = __testOnly.ComponentDefinitionModel
IframeComponent = __testOnly.IframeComponent

describe 'ComponentDefinitionModel', ->

  describe 'validate', ->
    attrs = undefined
    options= undefined
    model = undefined

    beforeEach ->
      model = new ComponentDefinitionModel()
      attrs = {}
      options = {}

    it 'should throw an error if attrs.id is undefined', ->
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id cant be undefined/

    it 'should throw an error if attrs.id is not a string', ->
      attrs.id = 123
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id should be a string/

    it 'should throw an error if attrs.id is an empty string', ->
      attrs.id = ' '
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /id can not be an empty string/

    it 'should throw an error if attrs.src is undefined', ->
      attrs.id = 'test'
      attrs.src = undefined
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /src cant be undefined/

    it 'should throw an error if attrs.src is not a string or a constructor function', ->
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
      attrs.src = MockComponent
      errorFn = -> model.validate attrs, options
      assert.doesNotThrow (-> errorFn()), /src should be a string or a constructor function/

    it 'should throw an error if attrs.src is an empty string', ->
      attrs.id = 'test'
      attrs.src = ' '
      errorFn = -> model.validate attrs, options
      assert.throws (-> errorFn()), /src can not be an empty string/


  describe 'getClass', ->
    it 'should return the IframeComponent class if src is a url', ->
      componentDefinitionObj =
        id: 'dummy'
        src: 'http://www.google.com'

      model = new ComponentDefinitionModel(componentDefinitionObj)
      klass = model.getClass()

      assert.equal klass, IframeComponent

    it 'should return src constructor function if set', ->

      componentDefinitionObj =
        id: 'dummy'
        src: '../test/spec/MockComponent'

      model = new ComponentDefinitionModel(componentDefinitionObj)
      klass = model.getClass()

      assert.equal klass, MockComponent

    # The two test below cant run in a nodejs environment the componentManager will
    # try to require the class instead of finding it on the window object.

    # it 'should should try to find the class on window if src is string but not a url', ->
    #   window.app = {}
    #   window.app.test = {}
    #   window.app.test.MockComponent = MockComponent

    #   componentDefinitionObj =
    #     id: 'dummy'
    #     src: 'app.test.MockComponent'

    #   model = new ComponentDefinitionModel(componentDefinitionObj)
    #   klass = model.getClass()

    #   assert.equal klass, MockComponent

    # it 'should throw an error if no class is found', ->
    #   componentDefinitionObj =
    #     id: 'dummy'
    #     src: 'app.test.TummyComponent'

    #   model = new ComponentDefinitionModel(componentDefinitionObj)

    #   errorFn = -> model.getClass()
    #   assert.throws (-> errorFn()), /No constructor function found for app.test.TummyComponent/

  describe 'areConditionsMet', ->
    it 'should return false if the condition is a method that returns falsy', ->
      falsyValues = [false, undefined, 0, '', null, NaN]
      for value in falsyValues
        componentDefinitionObj =
          id: 'dummy'
          src: MockComponent
          conditions: -> return value

        model = new ComponentDefinitionModel(componentDefinitionObj)
        assert.equal model.areConditionsMet(), false

    it 'should return true if the condition is a method that returns truthy', ->
      truthyValues = [true, {}, [], 42, 'foo', new Date()]
      for value in truthyValues
        componentDefinitionObj =
          id: 'dummy'
          src: MockComponent
          conditions: -> return value

        model = new ComponentDefinitionModel(componentDefinitionObj)
        assert.equal model.areConditionsMet(), true

    it 'should return false if one out of many condition returns false', ->
      falsyMethod = ->
        return false

      truthyMethod = ->
        return true

      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: [truthyMethod, falsyMethod, truthyMethod]

      model = new ComponentDefinitionModel(componentDefinitionObj)
      assert.equal model.areConditionsMet(), false

    it 'should return true if all of out of many condition returns true', ->
      truthyMethod = ->
        return true

      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: [truthyMethod, truthyMethod, truthyMethod]

      model = new ComponentDefinitionModel(componentDefinitionObj)
      assert.equal model.areConditionsMet(), true

    it 'should run condition method on globalConditions object if condition is a string', ->
      stub = sinon.stub()
      filter =
        url: 'foo'

      globalConditions =
        truthyMethod: stub.returns(true)

      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: 'truthyMethod'

      model = new ComponentDefinitionModel(componentDefinitionObj)
      model.areConditionsMet(filter, globalConditions)
      assert.ok stub.called

    it 'should run condition methods on globalConditions object if conditions is an array of strings', ->
      stub1 = sinon.stub()
      stub2 = sinon.stub()
      stub3 = sinon.stub()

      filter =
        url: 'foo'

      globalConditions =
        method1: stub1.returns(true)
        method2: stub2.returns(true)
        method3: stub3.returns(true)

      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: ['method1', 'method2', 'method3']

      model = new ComponentDefinitionModel(componentDefinitionObj)
      result = model.areConditionsMet(filter, globalConditions)
      assert.ok stub1.called
      assert.ok stub2.called
      assert.ok stub3.called

    it 'should return false if condition is a string and can be used as a key on the globalConditions object and that method returns falsy', ->
      falsyValues = [false, undefined, 0, '', null, NaN]
      filter =
        url: 'foo'

      for value in falsyValues
        stub = sinon.stub()
        globalConditions =
          truthyMethod: stub.returns(value)

        componentDefinitionObj =
          id: 'dummy'
          src: MockComponent
          conditions: 'truthyMethod'

        model = new ComponentDefinitionModel(componentDefinitionObj)
        result = model.areConditionsMet(filter, globalConditions)
        assert.equal result, false

    it 'should return true if condition is a string and can be used as a key on the globalConditions object and that method returns truthy', ->
      truthyValues = [true, {}, [], 42, 'foo', new Date()]
      filter =
        url: 'foo'

      for value in truthyValues
        stub = sinon.stub()
        globalConditions =
          truthyMethod: stub.returns(value)

        componentDefinitionObj =
          id: 'dummy'
          src: MockComponent
          conditions: 'truthyMethod'

        model = new ComponentDefinitionModel(componentDefinitionObj)
        result = model.areConditionsMet(filter, globalConditions)
        assert.equal result, true

    it 'should throw an error if the condition is a string and no globalConditions object is passed to the method ', ->
      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: 'truthyMethod'

      model = new ComponentDefinitionModel(componentDefinitionObj)
      errorFn = -> model.areConditionsMet()
      assert.throws (-> errorFn()), /No global conditions was passed, condition could not be tested/

    it 'should throw an error if the condition is a string and no mehod is registered with the string as a key in the globalConditions object', ->
      componentDefinitionObj =
        id: 'dummy'
        src: MockComponent
        conditions: 'truthyMethod'

      filter =
        url: 'foo'

      globalConditions =
        falsyMethod: -> return false

      model = new ComponentDefinitionModel(componentDefinitionObj)
      errorFn = -> model.areConditionsMet(filter, globalConditions)
      assert.throws (-> errorFn()), /Trying to verify condition truthyMethod but it has not been registered yet/

  describe '_isUrl', ->
    it 'should return true if string is url', ->
      model = new ComponentDefinitionModel()
      assert.equal model._isUrl('http://www.google.com'), true
      assert.equal model._isUrl('http://google.com'), true
      assert.equal model._isUrl('https://google.com'), true
      assert.equal model._isUrl('https://google.com?foo=bar'), true
      assert.equal model._isUrl('https://google.com:8080?foo=bar'), true
      assert.equal model._isUrl('https://google.com:8080/foo/bar/index.html'), true
      assert.equal model._isUrl('http://127.0.0.1:8079/'), true

    it 'should return false if string is not url', ->
      model = new ComponentDefinitionModel()
      assert.equal model._isUrl('test'), false
      assert.equal model._isUrl('http//google.com'), false
      assert.equal model._isUrl('/google'), false
      assert.equal model._isUrl('127.0.1:8079'), false
