assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'
Backbone = require 'backbone'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

router = __testOnly.router

describe 'Router', ->

  describe 'getArguments', ->
    it 'should call _getArgumentsFromUrl once for every matching urlPattern passing urlPattern and url', ->
      # One urlPattern
      _getArgumentsFromUrl = sinon.spy router.prototype, '_getArgumentsFromUrl'
      urlPatterns = ['foo/:id', 'bar/:id']
      url = 'foo/123'
      router.prototype.getArguments urlPatterns, url
      assert _getArgumentsFromUrl.calledOnce
      assert _getArgumentsFromUrl.calledWith 'foo/:id', 'foo/123'
      do _getArgumentsFromUrl.restore

      # Many urlPatterns
      _getArgumentsFromUrl = sinon.spy router.prototype, '_getArgumentsFromUrl'
      urlPatterns = ['foo/:id', 'foo/*splat']
      url = 'foo/123'
      router.prototype.getArguments urlPatterns, url
      assert _getArgumentsFromUrl.calledTwice
      assert _getArgumentsFromUrl.calledWith 'foo/:id', 'foo/123'
      do _getArgumentsFromUrl.restore

    it 'should return an array containing an url params object for each matching urlPattern', ->
      # One urlPattern
      urlPatterns = ['foo/:id', 'bar/:id']
      url = 'foo/123'
      args = router.prototype.getArguments urlPatterns, url
      expectedResults = [
        {
          _id: 'foo/:id'
          id: '123'
          url: 'foo/123'
        }
        {
          _id: 'bar/:id'
          url: 'foo/123'
        }
      ]
      assert.deepEqual args, expectedResults

      # Many urlPatterns
      urlPatterns = ['foo/:bar/:id', 'foo/*splat']
      url = 'foo/bar/123'
      expectedResults = [
        {
          _id: 'foo/:bar/:id'
          id: '123'
          bar: 'bar'
          url: 'foo/bar/123'
        }
        {
          _id: 'foo/*splat'
          splat: 'bar/123'
          url: 'foo/bar/123'
        }
      ]
      args = router.prototype.getArguments urlPatterns, url
      assert.deepEqual args, expectedResults

    it 'should add the passed url to each urlParams object', ->
      urlPatterns = ['foo/:id']
      url = 'foo/123'
      expectedResults = [
        {
          _id: 'foo/:id'
          id: '123'
          url: 'foo/123'
        }
      ]
      args = router.prototype.getArguments urlPatterns, url
      assert.deepEqual args, expectedResults




  describe 'routeToRegExp', ->
    it 'should call _routeToRegExp with passed urlPattern', ->
      _routeToRegExp = sinon.spy router.prototype, '_routeToRegExp'
      urlPattern = 'foo/:id'
      router.prototype.routeToRegExp urlPattern
      assert _routeToRegExp.calledWith urlPattern
      do _routeToRegExp.restore




  describe '_getArgumentsFromUrl', ->
    it 'should call _routeToRegExp with the urlPattern if it isnt already regexp', ->
      _routeToRegExp = sinon.spy router.prototype, '_routeToRegExp'
      url = 'foo/123'
      urlPattern = 'foo/:id'
      router.prototype._getArgumentsFromUrl urlPattern, url
      assert _routeToRegExp.calledWith urlPattern
      do _routeToRegExp.restore

      _routeToRegExp = sinon.spy router.prototype, '_routeToRegExp'
      url = 'foo/123'
      urlPattern = /[a-z]/
      router.prototype._getArgumentsFromUrl urlPattern, url
      assert _routeToRegExp.notCalled
      do _routeToRegExp.restore

    it 'should call _extractParameters with converted urlPattern and url', ->
      _extractParameters = sinon.spy router.prototype, '_extractParameters'
      url = 'foo/123'
      urlPattern = 'foo/:id'
      urlPatternRegExp = router.prototype._routeToRegExp(urlPattern)
      router.prototype._getArgumentsFromUrl urlPattern, url
      assert _extractParameters.calledWith urlPatternRegExp, url
      do _extractParameters.restore

    it 'should call _getParamsObject with passed urlPattern and extracted args', ->
      _getParamsObject = sinon.spy router.prototype, '_getParamsObject'
      url = 'foo/123'
      urlPattern = 'foo/:id'
      extractedParams = ['123']
      router.prototype._getArgumentsFromUrl urlPattern, url
      assert _getParamsObject.calledWith urlPattern, extractedParams
      do _getParamsObject.restore




  describe '_getParamsObject', ->
    it 'should extract keys from the urlPattern and assign correct values from the allready extracted arguments ', ->
      urlPattern = 'foo/:id'
      extractedParams = ['123']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        id: '123'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract multiple properties', ->
      urlPattern = 'foo/:foo/:bar/:baz'
      extractedParams = ['val1', 'val2', 'val3']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        foo: 'val1'
        bar: 'val2'
        baz: 'val3'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract splats', ->
      urlPattern = 'foo/*splat'
      extractedParams = ['val1/val2/val3']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        splat: 'val1/val2/val3'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract optional params', ->
      urlPattern = 'foo(/:bar)'
      extractedParams = ['val1']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        bar: 'val1'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract multiple optional params', ->
      urlPattern = 'foo(/:bar)(/:baz)(/:qux)'
      extractedParams = ['val1', 'val2', 'val3']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        bar: 'val1'
        baz: 'val2'
        qux: 'val3'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract params for patterns like search/:query/p:page', ->
      urlPattern = 'search/:query/p:page'
      extractedParams = ['myquery', '12']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        query: 'myquery'
        page: '12'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract params for patterns like folder/:name-:mode', ->
      urlPattern = 'folder/:name-:mode'
      extractedParams = ['myname', 'mymode']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults =
        name: 'myname'
        mode: 'mymode'

      assert.deepEqual paramsObject, expectedResults

    it 'should extract params if regexp is passed', ->
      urlPattern = /^(.*?)\/open$/
      extractedParams = ['myname', 'mymode']
      paramsObject = router.prototype._getParamsObject(urlPattern, extractedParams)
      expectedResults = ['myname', 'mymode']

      assert.deepEqual paramsObject, expectedResults
