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
    it 'should call instance.dispose if there are an instance', ->
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
    it 'should dispose the instance and set it to undefined on the instanceDefinitionModel', ->
      instance =
        render: ->
        dispose: sinon.spy()

      instanceDefinitionModel.set 'instance', instance
      instanceDefinitionModel.disposeInstance()
      assert instance.dispose.called
      instance = instanceDefinitionModel.get 'instance'
      assert.equal instance, undefined

  describe 'passesFilter', ->

  describe 'exceedsMaximumShowCount', ->
    it 'should return true if instance showCount exeeds instance maxShowCount', ->
      instanceDefinitionModel.set
        showCount: 2
        maxShowCount: 1

      exceeds = instanceDefinitionModel.exceedsMaximumShowCount()
      assert.equal exceeds, true

    it 'should return false if instance showCount is lower than the instance maxShowCount', ->
      instanceDefinitionModel.set
        showCount: 2
        maxShowCount: 4

      exceeds = instanceDefinitionModel.exceedsMaximumShowCount()
      assert.equal exceeds, false

    it 'should fallback on component maxShowCount if instance maxShowCount is undefined, (should return true if showCount exceeds componentMaxShowCount)', ->
      instanceDefinitionModel.set
        showCount: 4
        maxShowCount: undefined

      componentMaxShowCount = 3
      exceeds = instanceDefinitionModel.exceedsMaximumShowCount(componentMaxShowCount)
      assert.equal exceeds, true

    it 'should fallback on component maxShowCount if instance maxShowCount is undefined, (should return false if showCount is lower than componentMaxShowCount)', ->
      instanceDefinitionModel.set
        showCount: 2
        maxShowCount: undefined

      componentMaxShowCount = 3
      exceeds = instanceDefinitionModel.exceedsMaximumShowCount(componentMaxShowCount)
      assert.equal exceeds, false

    it 'sould return false if instance maxShowCount and component maxShowCount is undefined', ->
      instanceDefinitionModel.set
        showCount: 2
        maxShowCount: undefined

      componentMaxShowCount = undefined
      exceeds = instanceDefinitionModel.exceedsMaximumShowCount(componentMaxShowCount)
      assert.equal exceeds, false

  describe 'hasToMatchString', ->
    it 'should call includeIfStringMatches', ->
      sinon.spy instanceDefinitionModel, 'includeIfStringMatches'
      instanceDefinitionModel.hasToMatchString 'lorem ipsum'
      assert instanceDefinitionModel.includeIfStringMatches.called

    it 'should return true if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel.hasToMatchString 'lorem ipsum'
      assert.equal matches, true

    it 'should return false if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel.hasToMatchString 'lorem ipsum'
      assert.equal matches, false

    it 'should return false if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel.hasToMatchString 'lorem ipsum'
      assert.equal matches, false

  describe 'cantMatchString', ->
    it 'should call hasToMatchString', ->
      sinon.spy instanceDefinitionModel, 'hasToMatchString'
      instanceDefinitionModel.cantMatchString 'lorem ipsum'
      assert instanceDefinitionModel.hasToMatchString.called

    it 'should return false if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel.cantMatchString 'lorem ipsum'
      assert.equal matches, false

    it 'should return true if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel.cantMatchString 'lorem ipsum'
      assert.equal matches, true

    it 'should return true if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel.cantMatchString 'lorem ipsum'
      assert.equal matches, true

  describe 'includeIfStringMatches', ->
    it 'should return true if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel.includeIfStringMatches 'lorem ipsum'
      assert.equal matches, true

    it 'should return false if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel.includeIfStringMatches 'lorem ipsum'
      assert.equal matches, false

    it 'should return undefined if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', undefined
      matches = instanceDefinitionModel.includeIfStringMatches 'lorem ipsum'
      assert.equal matches, undefined

  describe 'doesUrlPatternMatch', ->
    it 'should return true if a single urlPattern matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1'
      assert.equal match, true

    it 'should return false if a single urlPattern does not match the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar'
      assert.equal match, false

    it 'should return true if one out of many urlPatterns matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar', 'bas/*splat']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1'
      assert.equal match, true

      match = instanceDefinitionModel.doesUrlPatternMatch 'bar'
      assert.equal match, true

    it 'should return false if the passed url doesnt match any of the urlPatterns', ->
      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar', 'bas/*splat']
      match = instanceDefinitionModel.doesUrlPatternMatch 'lorem'
      assert.equal match, false

      match = instanceDefinitionModel.doesUrlPatternMatch 'ipsum/lorem'
      assert.equal match, false

    it 'return undefined if the urlPattern is undefined', ->
      instanceDefinitionModel.set 'urlPattern', undefined
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo'
      assert.equal match, undefined

  describe 'addUrlParams', ->
