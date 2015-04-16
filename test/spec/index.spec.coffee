jsdom = require 'jsdom'
global.$ = require("jquery")(jsdom.jsdom().defaultView)
# global.$ = global.jQuery = require 'jquery'
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$

componentManager = require('../../dist/backbone.vigor.componentmanager').componentManager
assert = require 'assert'
sinon = require 'sinon'

describe 'A componentManager', ->


  describe 'initialize', ->

    componentSettings =
      "components": [],
      "hidden": [],
      "targets": {}

    componentManager.initialize {componentSettings: componentSettings}

    it '', ->

