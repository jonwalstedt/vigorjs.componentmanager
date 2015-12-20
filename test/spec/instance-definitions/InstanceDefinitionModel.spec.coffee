assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'
Backbone = require 'backbone'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly
InstanceDefinitionModel = __testOnly.InstanceDefinitionModel
FilterModel = __testOnly.FilterModel
router = __testOnly.router

describe 'InstanceDefinitionModel', ->

  instanceDefinitionModel = undefined
  sandbox = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()
    instanceDefinitionModel = new InstanceDefinitionModel()

  afterEach ->
    do sandbox.restore
    do instanceDefinitionModel.dispose
    instanceDefinitionModel = undefined



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

    it 'should throw an error if the targetName is not a string and not a jQuery object', ->
      attrs =
        id: 'my-instance-id'
        order: 10
        componentId: 'my-component-id'
        targetName: {}

      errorFn = -> instanceDefinitionModel.validate attrs
      assert.throws (-> errorFn()), /target should be a string or a jquery object/



  describe 'incrementShowCount', ->
    it 'should increment the showCount and update the model', ->
      assert.equal instanceDefinitionModel.get('showCount'), 0
      instanceDefinitionModel.incrementShowCount()
      assert.equal instanceDefinitionModel.get('showCount'), 1



  describe 'passesFilter', ->
    describe 'url filter', ->
      it 'should return true if filter.url matches urlPattern and no other filters
      are defined', ->
        instanceDefinitionModel.set 'urlPattern', 'foo/:id'
        filterModel = new FilterModel
          url: 'foo/123'

        passesFilter = instanceDefinitionModel.passesFilter filterModel
        assert.equal passesFilter, true

      it 'should return false if filter.url doesnt match urlPattern and no other filters are defined', ->
        instanceDefinitionModel.set 'urlPattern', 'foo/:id'
        filterModel = new FilterModel
          url: 'bar/123'
        passesFilter = instanceDefinitionModel.passesFilter filterModel
        assert.equal passesFilter, false

    describe 'conditions', ->
      it 'should call _areConditionsMet if conditions are set', ->
        instanceDefinitionModel.set 'conditions', -> return false
        sandbox.spy instanceDefinitionModel, '_areConditionsMet'
        instanceDefinitionModel.passesFilter()
        assert instanceDefinitionModel._areConditionsMet.called

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
        globalConditionsModel = new Backbone.Model
          foo: -> return true

        passesFilter = instanceDefinitionModel.passesFilter undefined, globalConditionsModel
        assert.equal passesFilter, true

      it 'should return false if globalConditions doesnt pass and no other filters are defined', ->
        instanceDefinitionModel.set 'conditions', 'foo'
        globalConditionsModel = new Backbone.Model
          foo: -> return false

        passesFilter = instanceDefinitionModel.passesFilter undefined, globalConditionsModel
        assert.equal passesFilter, false

    describe 'stringMatching - using a filterString on the passed filter', ->
      describe 'includeIfFilterStringMatches', ->
        it 'should return true if includeIfFilterStringMatches passes and no other filters are defined', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', 'foo'
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if includeIfFilterStringMatches doesnt pass and no other filters are defined', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', 'bar'
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if includeIfFilterStringMatches isnt defined and no other filters are defined - even if a filterString is set on the passed filter', ->
          instanceDefinitionModel.set 'includeIfFilterStringMatches', undefined
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

      describe 'excludeIfFilterStringMatches', ->
        it 'should return true if excludeIfFilterStringMatches passes and no other filters are defined', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'bar'
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if excludeIfFilterStringMatches doesnt pass and no other filters are defined', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'foo'
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if excludeIfFilterStringMatches isnt defined and no other filters are defined - even if a filterString is set on the passed filter', ->
          instanceDefinitionModel.set 'excludeIfFilterStringMatches', undefined
          filterModel = new FilterModel
            filterString: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true


    describe 'stringMatching - using a filterString on the instanceDefinition', ->
      describe 'forceFilterStringMatching', ->
        it 'should return false if the instanceDefinition has a filterString but the passed
        filter is not doing any string filtering and forceFilterStringMatching is enabled
        (this will make instanceDefinitions active only when the filter is doing string
        matching - even if other filters matches)', ->
          instanceDefinitionModel.set
            urlPattern: 'foo'
            filterString: 'bar'

          filterModel = new FilterModel
            url: 'foo'
            options:
              forceFilterStringMatching: true

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if the instanceDefinition has a filterString and the passed
        filter is doing string filtering and forceFilterStringMatching is enabled', ->
          instanceDefinitionModel.set
            urlPattern: 'foo'
            filterString: 'bar'

          filterModel = new FilterModel
            url: 'foo'
            hasToMatch: 'bar'
            options:
              forceFilterStringMatching: true

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if the instanceDefinition has a filterString and the passed
        filter is doing string filtering combined with other filtering and the other filtering fails
        and forceFilterStringMatching is enabled', ->
          instanceDefinitionModel.set
            urlPattern: 'foo'
            filterString: 'bar'

          filterModel = new FilterModel
            url: 'boo'
            hasToMatch: 'bar'
            options:
              forceFilterStringMatching: true

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if the instanceDefinition has a filterString but the passed
        filter is not doing any string filtering and forceFilterStringMatching is disabled', ->
          instanceDefinitionModel.set
            urlPattern: 'foo'
            filterString: 'bar'

          filterModel = new FilterModel
            url: 'foo'
            options:
              forceFilterStringMatching: false

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

      describe 'includeIfMatch', ->
        it 'should return true if includeIfMatch matches and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            includeIfMatch: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if includeIfMatch doesnt match and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            includeIfMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if includeIfMatch returns undefined and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', undefined
          filterModel = new FilterModel
            includeIfMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if includeIfMatch returns undefined and no other filters are defined and
        forceFilterStringMatching is set to true', ->
          instanceDefinitionModel.set 'filterString', undefined
          filterModel = new FilterModel
            includeIfMatch: 'bar'
            options:
              forceFilterStringMatching: true

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

      describe 'excludeIfMatch', ->
        it 'should return false if excludeIfMatch matches and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            excludeIfMatch: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

        it 'should return true if excludeIfMatch doesnt match and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            excludeIfMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return true if excludeIfMatch returns undefined and no other filters are defined', ->
          instanceDefinitionModel.set 'filterString', undefined
          filterModel = new FilterModel
            excludeIfMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if excludeIfMatch returns undefined and no other filters are defined and
        forceFilterStringMatching is set to true', ->
          instanceDefinitionModel.set 'filterString', undefined
          filterModel = new FilterModel
            includeIfMatch: 'bar'
            options:
              forceFilterStringMatching: true

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

      describe 'hasToMatch', ->
        it 'should return true if hasToMatch matches and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            hasToMatch: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if hasToMatch doesnt match and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            hasToMatch: 'bar'

        it 'should return false if hasToMatch is passed as a filter and no filterString is registered and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', undefined
          filterModel = new FilterModel
            hasToMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

      describe 'cantMatch', ->
        it 'should return true if cantMatch passes and no other filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            cantMatch: 'bar'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, true

        it 'should return false if cantMatch doesnt pass and no other
        filters are defnied', ->
          instanceDefinitionModel.set 'filterString', 'foo'
          filterModel = new FilterModel
            cantMatch: 'foo'

          passesFilter = instanceDefinitionModel.passesFilter filterModel
          assert.equal passesFilter, false

    describe 'should return', ->
      it 'true if no filter is passed', ->
        instanceDefinitionModel.set
          'urlPattern': 'foo/:bar/:baz'
          'filterString': 'foo'
          'conditions': -> return true

        passesFilter = instanceDefinitionModel.passesFilter()
        assert.equal passesFilter, true

      it 'true if all filter passes', ->
        instanceDefinitionModel.set
          'urlPattern': 'foo/:bar/:baz'
          'filterString': 'foo'
          'conditions': -> return true

        filterModel = new Backbone.Model
          url: 'foo/1/2'
          hasToMatch: 'foo'

        passesFilter = instanceDefinitionModel.passesFilter filterModel
        assert.equal passesFilter, true

      it 'false if any of the filters doesnt pass - in this case it passes the hasToMatch filter butthe conditions does not pass', ->
        instanceDefinitionModel.set
          'urlPattern': 'foo/:bar/:baz'
          'filterString': 'foo'
          'conditions': -> return false

        filterModel = new Backbone.Model
          url: 'foo/1/2'
          hasToMatch: 'foo'

        passesFilter = instanceDefinitionModel.passesFilter filterModel
        assert.equal passesFilter, false

      it 'false if any of the filters doesnt pass - in this case the url pattern does not match', ->
        instanceDefinitionModel.set
          'urlPattern': 'bar/:baz/:qux'
          'filterString': 'foo'
          'conditions': -> return true

        filterModel = new Backbone.Model
          url: 'foo/1/2'
          hasToMatch: 'foo'

        passesFilter = instanceDefinitionModel.passesFilter filterModel
        assert.equal passesFilter, false

      it 'false if any of the filters doesnt pass - in this case the filterString cant match foo', ->
        instanceDefinitionModel.set
          'urlPattern': 'foo/:baz/:qux'
          'filterString': 'foo'
          'conditions': -> return true

        filterModel = new Backbone.Model
          url: 'foo/1/2'
          cantMatch: 'foo'

        passesFilter = instanceDefinitionModel.passesFilter filterModel
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

    it 'should fallback on component maxShowCount if instance maxShowCount is undefined,
    (should return true if showCount exceeds componentMaxShowCount)', ->
      instanceDefinitionModel.set
        showCount: 4
        maxShowCount: undefined

      componentMaxShowCount = 3
      exceeds = instanceDefinitionModel.exceedsMaximumShowCount(componentMaxShowCount)
      assert.equal exceeds, true

    it 'should fallback on component maxShowCount if instance maxShowCount is undefined,
    (should return false if showCount is lower than componentMaxShowCount)', ->
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



  describe 'dispose', ->
    it 'should call clear', ->
      sandbox.spy instanceDefinitionModel, 'clear'
      instanceDefinitionModel.dispose()
      assert instanceDefinitionModel.clear.called



  describe 'isTargetAvailable', ->
    it 'should call getTarget', ->
      instanceDefinitionModel.set 'targetName', 'my-non-existing-dom-element-class-name'
      sandbox.spy instanceDefinitionModel, 'getTarget'
      do instanceDefinitionModel.isTargetAvailable
      assert instanceDefinitionModel.getTarget.called

    it 'should return true if the target is present in the DOM', ->
      $('body').append '<div class="my-existing-dom-element-class-name"></div>'
      instanceDefinitionModel.set 'targetName', 'my-existing-dom-element-class-name'
      sandbox.spy instanceDefinitionModel, 'getTarget'
      isAvailable = do instanceDefinitionModel.isTargetAvailable
      assert.equal isAvailable, true
      do $('.my-existing-dom-element-class-name').remove

    it 'should return false if the target is not present in the DOM', ->
      instanceDefinitionModel.set 'targetName', 'my-non-existing-dom-element-class-name'
      sandbox.spy instanceDefinitionModel, 'getTarget'
      isAvailable = do instanceDefinitionModel.isTargetAvailable
      assert.equal isAvailable, false



  describe 'getTarget', ->
    beforeEach ->
      $('body').append '<div class="component-area--test-target"></div>'

    afterEach ->
      do $('.component-area--test-target').remove

    it 'should call _refreshTarget if targetName isnt present in the _$target.selector', ->
      instanceDefinitionModel.set 'targetName', 'component-area--test-target'
      instanceDefinitionModel._$target = $ 'body'
      refreshTargetSpy = sandbox.spy instanceDefinitionModel, '_refreshTarget'

      do instanceDefinitionModel.getTarget
      assert refreshTargetSpy.called

    it 'should not call _refreshTarget if targetName is present in the _$target.selector', ->
      instanceDefinitionModel.set 'targetName', 'component-area--test-target'
      instanceDefinitionModel._$target = $ '.component-area--test-target'
      refreshTargetSpy = sandbox.spy instanceDefinitionModel, '_refreshTarget'

      do instanceDefinitionModel.getTarget
      assert refreshTargetSpy.notCalled

    it 'should return _$target', ->
      $target = $ '.component-area--test-target'
      instanceDefinitionModel.set 'targetName', 'component-area--test-target'
      instanceDefinitionModel._$target = $target

      result = do instanceDefinitionModel.getTarget
      assert.equal result, $target



  describe 'unsetTarget', ->
    it 'should set this._$target to undefined', ->
      instanceDefinitionModel._$target = $('body')
      assert instanceDefinitionModel._$target
      assert.equal instanceDefinitionModel._$target.length, 1

      do instanceDefinitionModel.unsetTarget

      assert.equal instanceDefinitionModel._$target, undefined



  describe 'updateTargetPrefix', ->
    it 'should update targetName with the new prefix', ->
      instanceDefinitionModel.set 'targetName', 'component-area--main'
      setSpy = sandbox.spy instanceDefinitionModel, 'set'
      assert.equal instanceDefinitionModel.get('targetName'), 'component-area--main'

      instanceDefinitionModel.updateTargetPrefix 'new-prefix'
      assert.equal instanceDefinitionModel.get('targetName'), 'new-prefix--main'




  describe '_hasToMatch', ->
    it 'should call _includeIfMatch', ->
      sandbox.spy instanceDefinitionModel, '_includeIfMatch'
      instanceDefinitionModel._hasToMatch 'lorem ipsum'
      assert instanceDefinitionModel._includeIfMatch.called

    it 'should return true if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel._hasToMatch 'lorem ipsum'
      assert.equal matches, true

    it 'should return false if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel._hasToMatch 'lorem ipsum'
      assert.equal matches, false

    it 'should return false if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel._hasToMatch 'lorem ipsum'
      assert.equal matches, false




  describe '_cantMatch', ->
    it 'should call _excludeIfMatch', ->
      sandbox.spy instanceDefinitionModel, '_excludeIfMatch'
      instanceDefinitionModel._cantMatch 'lorem ipsum'
      assert instanceDefinitionModel._excludeIfMatch.called

    it 'should return false if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel._cantMatch 'lorem ipsum'
      assert.equal matches, false

    it 'should return true if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel._cantMatch 'lorem ipsum'
      assert.equal matches, true

    it 'should return true if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel._cantMatch 'lorem ipsum'
      assert.equal matches, true




  describe '_includeIfMatch', ->
    it 'should return true if string matches', ->
      instanceDefinitionModel.set 'filterString', 'lorem ipsum dolor'
      matches = instanceDefinitionModel._includeIfMatch 'lorem ipsum'
      assert.equal matches, true

    it 'should return false if string doesnt match', ->
      instanceDefinitionModel.set 'filterString', 'foo bar'
      matches = instanceDefinitionModel._includeIfMatch 'lorem ipsum'
      assert.equal matches, false

    it 'should return undefined if filterString is undefined', ->
      instanceDefinitionModel.set 'filterString', undefined
      matches = instanceDefinitionModel._includeIfMatch 'lorem ipsum'
      assert.equal matches, undefined

    it 'should handle a regexp as passed filterString', ->
      instanceDefinitionModel.set 'filterString', 'foo/bar/baz'
      matches = instanceDefinitionModel._includeIfMatch /[a-z]+/g
      assert.equal matches, true




  describe '_includeIfFilterStringMatches', ->
    it 'should return true if _includeIfFilterStringMatches is defined and matches filterString', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel._includeIfFilterStringMatches 'lorem ipsum dolor'
      assert.equal matches, true

    it 'should return false if _includeIfFilterStringMatches is defined and does not match the filterString', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel._includeIfFilterStringMatches 'foo bar'
      assert.equal matches, false

    it 'should return undefined if _includeIfFilterStringMatches is undefined', ->
      instanceDefinitionModel.set 'includeIfFilterStringMatches', undefined
      matches = instanceDefinitionModel._includeIfFilterStringMatches 'lorem ipsum'
      assert.equal matches, undefined




  describe '_excludeIfFilterStringMatches', ->
    it 'should return false if _excludeIfFilterStringMatches is defined and matches filterString', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel._excludeIfFilterStringMatches 'lorem ipsum dolor'
      assert.equal matches, false

    it 'should return true if _excludeIfFilterStringMatches is defined and does not match the filterString', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', 'lorem ipsum'
      matches = instanceDefinitionModel._excludeIfFilterStringMatches 'foo bar'
      assert.equal matches, true

    it 'should return undefined if _excludeIfFilterStringMatches is undefined', ->
      instanceDefinitionModel.set 'excludeIfFilterStringMatches', undefined
      matches = instanceDefinitionModel._excludeIfFilterStringMatches 'lorem ipsum'
      assert.equal matches, undefined




  describe '_doesUrlPatternMatch', ->
    it 'should call router.routeToRegExp with the urlPattern', ->
      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      sandbox.spy router.prototype, 'routeToRegExp'
      instanceDefinitionModel._doesUrlPatternMatch 'foo/1'
      assert router.prototype.routeToRegExp.calledWith 'foo/:id'

    it 'should return true if a single urlPattern matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:name-:mode'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:type/:page/:id'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/*splat'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)(/:qux)'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

    it 'should return false if a single urlPattern does not match the passed url', ->
      instanceDefinitionModel.set 'urlPattern', 'foo'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:id'
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:name-:mode'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/bar-baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:type/:page/:id'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/*splat'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', 'foo/:bar(/:baz)(/:qux)'
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, false

    it 'should return true if one out of many urlPatterns matches the passed url', ->
      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/bar-baz'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2/3'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel._doesUrlPatternMatch 'bar/1/2'
      assert.equal match, true

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)(/:qux)', 'bar/:baz(/:qux)(/:quux)']
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo/1/2/3'
      assert.equal match, true

    it 'should return false if the passed url doesnt match any of the urlPatterns', ->
      instanceDefinitionModel.set 'urlPattern', ['foo', 'bar']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:id', 'bar/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/1'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:name-:mode', 'bar/:name-:mode']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/bar-baz'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:type/:page/:id', 'bar/:type/:page/:id']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/*splat', 'bar/*splat']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)', 'bar/:baz(/:qux)']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/1/2'
      assert.equal match, false

      instanceDefinitionModel.set 'urlPattern', ['foo/:bar(/:baz)(/:qux)', 'bar/:baz(/:qux)(/:quux)']
      match = instanceDefinitionModel._doesUrlPatternMatch 'baz/1/2/3'
      assert.equal match, false

    it 'should return true if the passed url is an empty string and the urlPattern 
    is an empty string', ->
      instanceDefinitionModel.set 'urlPattern', ''
      match = instanceDefinitionModel._doesUrlPatternMatch ''
      assert.equal match, true

      match = instanceDefinitionModel._doesUrlPatternMatch 'foo'
      assert.equal match, false

    it 'return undefined if the urlPattern is undefined', ->
      instanceDefinitionModel.set 'urlPattern', undefined
      match = instanceDefinitionModel._doesUrlPatternMatch 'foo'
      assert.equal match, undefined




  describe '_areConditionsMet', ->
    it 'should return true if instanceConditions is undefined', ->
      instanceDefinitionModel.set 'conditions', undefined
      areConditionsMet = instanceDefinitionModel._areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return true if the condition is a method that returns true', ->
      instanceDefinitionModel.set 'conditions', -> return true
      areConditionsMet = instanceDefinitionModel._areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return false if the condition is a method that returns false', ->
      instanceDefinitionModel.set 'conditions', -> return false
      areConditionsMet = instanceDefinitionModel._areConditionsMet()
      assert.equal areConditionsMet, false

    it 'should return true if there are multiple conditions and all of them returns true', ->
      instanceDefinitionModel.set 'conditions', [
        -> return true,
        -> return true,
        -> return true
      ]
      areConditionsMet = instanceDefinitionModel._areConditionsMet()
      assert.equal areConditionsMet, true

    it 'should return false if there are multiple conditions and any of them returns false', ->
      instanceDefinitionModel.set 'conditions', [
        -> return true,
        -> return true,
        -> return false
      ]
      areConditionsMet = instanceDefinitionModel._areConditionsMet()
      assert.equal areConditionsMet, false

    it 'should use methods in globalConditions if the condition is a string
    (the string will be used as a key in the globalConditions object)', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      filter = undefined
      globalConditions =
        fooCheck: sandbox.spy()

      areConditionsMet = instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert globalConditions.fooCheck.called

    it 'should return true if targeted method in globalConditions returns true', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      filter = undefined
      globalConditions =
        fooCheck: -> return true

      areConditionsMet = instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert.equal areConditionsMet, true

    it 'should return false if targeted method in globalConditions returns false', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      filter = undefined
      globalConditions =
        fooCheck: -> return false

      areConditionsMet = instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert.equal areConditionsMet, false

    it 'should return true if all targeted methods in globalConditions returns true', ->
      instanceDefinitionModel.set 'conditions', ['fooCheck', 'barCheck', 'bazCheck']
      filter = undefined
      globalConditions =
        fooCheck: -> return true
        barCheck: -> return true
        bazCheck: -> return true

      areConditionsMet = instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert.equal areConditionsMet, true

    it 'should return false if any of the targeted methods in globalConditions returns false', ->
      instanceDefinitionModel.set 'conditions', ['fooCheck', 'barCheck', 'bazCheck']
      filter = undefined
      globalConditions =
        fooCheck: -> return true
        barCheck: -> return false
        bazCheck: -> return true

      areConditionsMet = instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert.equal areConditionsMet, false

    it 'should throw an error if the condition is a string and no global conditions was passed', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      errorFn = -> instanceDefinitionModel._areConditionsMet()
      assert.throws (-> errorFn()), /No global conditions was passed, condition could not be tested/

    it 'should throw an error if the condition is a string and the key is not
    present in the globalConditions', ->
      instanceDefinitionModel.set 'conditions', 'fooCheck'
      filter = undefined
      globalConditions =
        barCheck: -> return true

      errorFn = -> instanceDefinitionModel._areConditionsMet(filter, globalConditions)
      assert.throws (-> errorFn()), /Trying to verify condition fooCheck but it has not been registered yet/



  describe '_refreshTarget', ->
    beforeEach ->
      $('body').append '<div class="header"></div>'
      $('.header').append '<div class="component-area--test-target" id="test-target"></div>'

    afterEach ->
      do $('.component-area--test-target').remove

    it 'should store the target on the instanceDefinition to cache it for future
    calls', ->
      $expectedResult = $ '.component-area--test-target'
      instanceDefinitionModel.set 'targetName', $expectedResult
      assert.equal instanceDefinitionModel._$target, undefined
      do instanceDefinitionModel._refreshTarget
      assert.equal instanceDefinitionModel._$target, $expectedResult

    it 'should return the stored target', ->
      $expectedResult = $ '.component-area--test-target'
      instanceDefinitionModel.set 'targetName', $expectedResult
      assert.equal instanceDefinitionModel._$target, undefined
      $result = do instanceDefinitionModel._refreshTarget
      assert.equal $result, $expectedResult

    describe 'if targetName is a string', ->
      it 'should try to find the target as a jQuery object but ignore the context
      if the targetName is "body"', ->
        instanceDefinitionModel.set 'targetName', 'body'
        $target = do instanceDefinitionModel.getTarget
        assert $target instanceof $
        assert.equal $target.selector, 'body'

      it 'should try to find the target as a jQuery object within the context if
      the targetName is not "body"', ->
        instanceDefinitionModel.set 'targetName', 'component-area--test-target', silent: true
        $target = instanceDefinitionModel.getTarget $('.header')
        assert $target instanceof $
        assert.equal $target.selector, '.header .component-area--test-target'

    describe 'if targetName is not a string', ->
      it 'should set the target to targetName if targetName already is a jQuery object', ->
        $expectedResult = $ '.component-area--test-target'
        instanceDefinitionModel.set 'targetName', $expectedResult
        $target = do instanceDefinitionModel.getTarget
        assert $target instanceof $
        assert.equal $target, $expectedResult

      it 'should throw an TARGET.WRONG_FORMAT error if its targetName is not a
      jQuery object and not a string', ->
        instanceDefinitionModel.set 'targetName', {}, silent: true
        errorFn = -> do instanceDefinitionModel.getTarget
        assert.throws (-> errorFn()), /target should be a string or a jquery object/



  describe '_getTargetName', ->
    it 'should return the target name prefixed with a period (class selector)', ->
      targetName = 'vigor-component--test'
      expectedResults = '.vigor-component--test'
      instanceDefinitionModel.set targetName: targetName
      result = instanceDefinitionModel._getTargetName()
      assert.equal result, expectedResults

    it 'should return the target name prefixed with a period (class selector) even
      if it already has it ', ->
      targetName = '.vigor-component--test'
      expectedResults = '.vigor-component--test'
      instanceDefinitionModel.set targetName: targetName
      result = instanceDefinitionModel._getTargetName()
      assert.equal result, expectedResults

    it 'should not prefix the selector "body" with a period', ->
      targetName = 'body'
      expectedResults = 'body'
      instanceDefinitionModel.set targetName: targetName
      result = instanceDefinitionModel._getTargetName()
      assert.equal result, expectedResults
