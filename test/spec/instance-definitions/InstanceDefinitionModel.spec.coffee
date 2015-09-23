assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'
Backbone = require 'backbone'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel
router = __testOnly.router

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

      instanceDefinitionModel.set
        'id': 'test'
        'instance': instance

      errorFn = -> instanceDefinitionModel.renderInstance()

      assert.throws (-> errorFn()), /The instance for test does not have a render method/

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
    describe 'url filter', ->
      it 'should return true if filter.url matches urlPattern and no other filters are defined', ->
        instanceDefinitionModel.set 'urlPattern', 'foo/:id'
        passesFilter = instanceDefinitionModel.passesFilter url: 'foo/123'
        assert.equal passesFilter, true

      it 'should return false if filter.url doesnt match urlPattern and no other filters are defined', ->
        instanceDefinitionModel.set 'urlPattern', 'foo/:id'
        passesFilter = instanceDefinitionModel.passesFilter url: 'bar/123'
        assert.equal passesFilter, false

    describe 'conditions', ->
      it 'should call areConditionsMet if conditions are set', ->
        instanceDefinitionModel.set 'conditions', -> return false
        sinon.spy instanceDefinitionModel, 'areConditionsMet'
        instanceDefinitionModel.passesFilter()
        assert instanceDefinitionModel.areConditionsMet.called

      it 'should return true if conditions passes and no other filters are defined', ->
        instanceDefinitionModel.set 'conditions', -> return true
        passesFilter = instanceDefinitionModel.passesFilter()
        assert.equal passesFilter, true

      it 'should return false if conditions doesnt pass and no other filters are defined', ->
        instanceDefinitionModel.set 'conditions', -> return false
        passesFilter = instanceDefinitionModel.passesFilter()
        assert.equal passesFilter, false

      it 'should return true if globalConditions passes and no other filters are defined', ->
        instanceDefinitionModel.set 'conditions', 'foo'
        globalConditions =
          foo: -> return true

        passesFilter = instanceDefinitionModel.passesFilter undefined, globalConditions
        assert.equal passesFilter, true

      it 'should return false if globalConditions doesnt pass and no other filters are defined', ->
        instanceDefinitionModel.set 'conditions', 'foo'
        globalConditions =
          foo: -> return false

        passesFilter = instanceDefinitionModel.passesFilter undefined, globalConditions
        assert.equal passesFilter, false

    describe 'stringMatching - using a filterString on the passed filter', ->
      describe 'includeIfFilterStringMatches', ->
        it 'should return true if includeIfFilterStringMatches passes and no other filters are defined', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', 'foo'
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

        it 'should return false if includeIfFilterStringMatches doesnt pass and no other filters are defined', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', 'bar'
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, false

        it 'should return true if includeIfFilterStringMatches isnt defined and no other filters are defined - even if a filterString is set on the passed filter', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', undefined
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

      describe 'excludeIfFilterStringMatches', ->
        it 'should return true if excludeIfFilterStringMatches passes and no other filters are defined', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'bar'
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

        it 'should return false if excludeIfFilterStringMatches doesnt pass and no other filters are defined', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'foo'
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, false

        it 'should return true if excludeIfFilterStringMatches isnt defined and no other filters are defined - even if a filterString is set on the passed filter', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', undefined
          filter =
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true


    describe 'stringMatching - using a filterString on the instanceDefinition', ->
      describe 'includeIfStringMatches', ->
        it 'should return true if includeIfStringMatches matches and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            includeIfStringMatches: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

        it 'should return false if includeIfStringMatches doesnt match and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            includeIfStringMatches: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, false

        it 'should return true if includeIfStringMatches returns undefined and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', undefined
          filter =
            includeIfStringMatches: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

      describe 'hasToMatchString', ->
        it 'should return true if hasToMatchString matches and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            hasToMatchString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

        it 'should return false if hasToMatchString doesnt match and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            hasToMatchString: 'bar'

        it 'should return false if hasToMatchString is passed as a filter and no filterString is registered and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', undefined
          filter =
            hasToMatchString: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, false

      describe 'cantMatchString', ->
        it 'should return true if cantMatchString passes and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            cantMatchString: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, true

        it 'should return false if cantMatchString doesnt pass and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filter =
            cantMatchString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filter
          assert.equal passesFilter, false

    it 'should return true if no filter is passed', ->
      instanceDefinitionModel.set
        'urlPattern': 'foo/:bar/:baz'
        'filterString': 'foo'
        'conditions': -> return true

      passesFilter = instanceDefinitionModel.passesFilter()
      assert.equal passesFilter, true

    it 'returns true if all filter passes', ->
      instanceDefinitionModel.set
        'urlPattern': 'foo/:bar/:baz'
        'filterString': 'foo'
        'conditions': -> return true

      filter =
        url: 'foo/1/2'
        hasToMatchString: 'foo'

      passesFilter = instanceDefinitionModel.passesFilter filter
      assert.equal passesFilter, true

    it 'returns false if any of the filters doesnt pass - in this case it passes the hasToMatchString filter butthe conditions does not pass', ->
      instanceDefinitionModel.set
        'urlPattern': 'foo/:bar/:baz'
        'filterString': 'foo'
        'conditions': -> return false

      filter =
        url: 'foo/1/2'
        hasToMatchString: 'foo'

      passesFilter = instanceDefinitionModel.passesFilter filter
      assert.equal passesFilter, false

    it 'returns false if any of the filters doesnt pass - in this case the url pattern does not match', ->
      instanceDefinitionModel.set
        'urlPattern': 'bar/:baz/:qux'
        'filterString': 'foo'
        'conditions': -> return true

      filter =
        url: 'foo/1/2'
        hasToMatchString: 'foo'

      passesFilter = instanceDefinitionModel.passesFilter filter
      assert.equal passesFilter, false

    it 'returns false if any of the filters doesnt pass - in this case the filterString cant match foo', ->
      instanceDefinitionModel.set
        'urlPattern': 'foo/:baz/:qux'
        'filterString': 'foo'
        'conditions': -> return true

      filter =
        url: 'foo/1/2'
        cantMatchString: 'foo'

      passesFilter = instanceDefinitionModel.passesFilter filter
      assert.equal passesFilter, false

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
    it 'should call excludeIfStringMatches', ->
      sinon.spy instanceDefinitionModel, 'excludeIfStringMatches'
      instanceDefinitionModel.cantMatchString 'lorem ipsum'
      assert instanceDefinitionModel.excludeIfStringMatches.called

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

    it 'should handle a regexp as passed filterString', ->
      instanceDefinitionModel.set 'filterString', 'foo/bar/baz'
      matches = instanceDefinitionModel.includeIfStringMatches /[a-z]+/g
      assert.equal matches, true

  describe 'includeIfFilterStringMatches', ->
    it 'should return true if includeIfFilterStringMatches is defined and matches filterString', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel.includeIfFilterStringMatches 'lorem ipsum dolor'
      assert.equal matches, true

    it 'should return false if includeIfFilterStringMatches is defined and does not match the filterString', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel.includeIfFilterStringMatches 'foo bar'
      assert.equal matches, false

    it 'should return undefined if includeIfFilterStringMatches is undefined', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', undefined
      matches = instanceDefinitionModel.includeIfFilterStringMatches 'lorem ipsum'
      assert.equal matches, undefined

  describe 'excludeIfFilterStringMatches', ->
    it 'should return false if excludeIfFilterStringMatches is defined and matches filterString', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel.excludeIfFilterStringMatches 'lorem ipsum dolor'
      assert.equal matches, false

    it 'should return true if excludeIfFilterStringMatches is defined and does not match the filterString', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel.excludeIfFilterStringMatches 'foo bar'
      assert.equal matches, true

    it 'should return undefined if excludeIfFilterStringMatches is undefined', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', undefined
      matches = instanceDefinitionModel.excludeIfFilterStringMatches 'lorem ipsum'
      assert.equal matches, undefined

  describe 'doesUrlPatternMatch', ->
    it 'should call router.routeToRegExp with the urlPattern', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      sinon.spy router.prototype, 'routeToRegExp'
      instanceDefinitionModel.doesUrlPatternMatch 'foo/1'
      assert router.prototype.routeToRegExp.calledWith 'foo/:id'

    it 'should return true if a single urlPattern matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:name-:mode'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:type/:page/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/*splat'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)(/:qux)'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

    it 'should return false if a single urlPattern does not match the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:name-:mode'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/bar-baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:type/:page/:id'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/*splat'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)(/:qux)'
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

    it 'should return true if one out of many urlPatterns matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel.doesUrlPatternMatch 'bar/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)(/:qux)', 'bar/:baz(/:qux)(/:quux)']
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

    it 'should return false if the passed url doesnt match any of the urlPatterns', ->
      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/1'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/bar-baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)(/:qux)', 'bar/:baz(/:qux)(/:quux)']
      match = instanceDefinitionModel.doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

    it 'return undefined if the urlPattern is undefined', ->
      instanceDefinitionModel.set 'urlPattern', undefined
      match = instanceDefinitionModel.doesUrlPatternMatch 'foo'
      assert.equal match, undefined

  describe 'areConditionsMet', ->
    it 'should return true if instanceConditions is undefined', ->
      instanceDefinitionModel.set 'conditions', undefined
      areConditionsMet = instanceDefinitionModel.areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return true if the condition is a method that returns true', ->
      instanceDefinitionModel.set 'conditions', -> return true
      areConditionsMet = instanceDefinitionModel.areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return false if the condition is a method that returns false', ->
      instanceDefinitionModel.set 'conditions', -> return false
      areConditionsMet = instanceDefinitionModel.areConditionsMet()
      assert.equal areConditionsMet, false

    it 'should return true if there are multiple conditions and all of them returns true', ->
      instanceDefinitionModel.set 'conditions', [
        -> return true,
        -> return true,
        -> return true
      ]
      areConditionsMet = instanceDefinitionModel.areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return false if there are multiple conditions and any of them returns false', ->
      instanceDefinitionModel.set 'conditions', [
        -> return true,
        -> return true,
        -> return false
      ]
      areConditionsMet = instanceDefinitionModel.areConditionsMet()
      assert.equal areConditionsMet, false

    it 'should use methods in globalConditions if the condition is a string (the string will be used as a key in the globalConditions object)', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      globalConditions =
        fooCheck: sinon.spy()

      areConditionsMet = instanceDefinitionModel.areConditionsMet(globalConditions)
      assert globalConditions.fooCheck.called

    it 'should return true if targeted method in globalConditions returns true', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      globalConditions =
        fooCheck: -> return true

      areConditionsMet = instanceDefinitionModel.areConditionsMet(globalConditions)
      assert.equal areConditionsMet, true

    it 'should return false if targeted method in globalConditions returns false', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      globalConditions =
        fooCheck: -> return false

      areConditionsMet = instanceDefinitionModel.areConditionsMet(globalConditions)
      assert.equal areConditionsMet, false

    it 'should return true if all targeted methods in globalConditions returns true', ->
      instanceDefinitionModel.set 'conditions', ['fooCheck', 'barCheck', 'bazCheck']
      globalConditions =
        fooCheck: -> return true
        barCheck: -> return true
        bazCheck: -> return true

      areConditionsMet = instanceDefinitionModel.areConditionsMet(globalConditions)
      assert.equal areConditionsMet, true

    it 'should return false if any of the targeted methods in globalConditions returns false', ->
      instanceDefinitionModel.set 'conditions', ['fooCheck', 'barCheck', 'bazCheck']
      globalConditions =
        fooCheck: -> return true
        barCheck: -> return false
        bazCheck: -> return true

      areConditionsMet = instanceDefinitionModel.areConditionsMet(globalConditions)
      assert.equal areConditionsMet, false

    it 'should throw an error if the condition is a string and no global conditions was passed', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      errorFn = -> instanceDefinitionModel.areConditionsMet()
      assert.throws (-> errorFn()), /No global conditions was passed, condition could not be tested/

    it 'should throw an error if the condition is a string and the key is not present in the globalConditions', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      globalConditions =
        barCheck: -> return true

      errorFn = -> instanceDefinitionModel.areConditionsMet(globalConditions)
      assert.throws (-> errorFn()), /Trying to verify condition fooCheck but it has not been registered yet/

  describe 'addUrlParams', ->
    it 'should call router.getArguments with registered urlPattern and passedd url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      sinon.spy router.prototype, 'getArguments'
      instanceDefinitionModel.addUrlParams 'foo/123'
      assert router.prototype.getArguments.calledWith 'foo/:id', 'foo/123'

    it 'should create a new urlParamsModel if it does not exist already', ->
      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'
      assert.equal urlParamsModel, undefined

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.addUrlParams 'foo/123'

      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'
      assert urlParamsModel instanceof Backbone.Model

    it 'should update the urlParamsModel with the extracted url params and the url itself', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.addUrlParams 'foo/123'
      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'
      assert.equal urlParamsModel.get('id'), 123
      assert.equal urlParamsModel.get('url'), 'foo/123'

      instanceDefinitionModel.set 'urlPattern', 'foo/:type(/:id)'
      instanceDefinitionModel.addUrlParams 'foo/article/123'
      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'
      assert.equal urlParamsModel.get('type'), 'article'
      assert.equal urlParamsModel.get('id'), 123
      assert.equal urlParamsModel.get('url'), 'foo/article/123'

    it 'should update the urlParams property with the extracted url params and the url itself', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.addUrlParams 'foo/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      assert.equal urlParams[0].id, 123
      assert.equal urlParams[0].url, 'foo/123'

    it 'should trigger a change event when updating the urlParams if reInstantiateOnUrlParamChange is set to true', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.set 'reInstantiateOnUrlParamChange', true
      sinon.spy instanceDefinitionModel, 'trigger'
      instanceDefinitionModel.addUrlParams 'foo/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      assert instanceDefinitionModel.trigger.calledWith 'change:urlParams', instanceDefinitionModel, urlParams, { silent: false }

    it 'should not update the urlParams if the urlPattern doesnt match the url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.addUrlParams 'bar/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      assert.equal urlParams, undefined

    it 'should not update the urlParams if none out of many urlPatterns doesnt match the url', ->
      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id', 'baz/:id']
      instanceDefinitionModel.addUrlParams 'qux/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      assert.equal urlParams, undefined

    it 'should not trigger a change event when updating the urlParams if reInstantiateOnUrlParamChange is set to false', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      instanceDefinitionModel.set 'reInstantiateOnUrlParamChange', false
      sinon.spy instanceDefinitionModel, 'trigger'
      instanceDefinitionModel.addUrlParams 'foo/123'
      assert instanceDefinitionModel.trigger.notCalled

    it 'should should be able to handle multiple urlPatterns with only one matching', ->
      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'foo/:bar/:id']
      instanceDefinitionModel.addUrlParams 'foo/bar/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'

      assert.equal urlParams.length, 1
      assert.equal urlParams[0].bar, 'bar'
      assert.equal urlParams[0].id, 123
      assert.equal urlParams[0].url, 'foo/bar/123'
      assert.deepEqual urlParamsModel.toJSON(), urlParams[0]

    it 'should should be able to handle multiple urlPatterns with multiple matches', ->
      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'foo/:bar/:id', 'bar/:id', 'foo/*path']
      instanceDefinitionModel.addUrlParams 'foo/bar/123'
      urlParams = instanceDefinitionModel.get 'urlParams'
      urlParamsModel = instanceDefinitionModel.get 'urlParamsModel'

      assert.equal urlParams.length, 2
      assert.equal urlParams[0].bar, 'bar'
      assert.equal urlParams[0].id, 123
      assert.equal urlParams[0].url, 'foo/bar/123'
      assert.equal urlParams[1].path, 'bar/123'
      assert.equal urlParams[1].url, 'foo/bar/123'
      assert.deepEqual urlParamsModel.toJSON(), urlParams[0]

