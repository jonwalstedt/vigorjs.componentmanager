jsdom = require 'jsdom'
global.$ = require("jquery")(jsdom.jsdom().parentWindow)
global._ = require 'underscore'
global.Backbone = require 'backbone'
global.Backbone.$ = global.$

componentManager = require('../../dist/backbone.vigor.componentmanager').componentManager
assert = require 'assert'
sinon = require 'sinon'

describe 'A componentManager', ->

  console.log componentManager
  describe 'initialize', ->

    componentSettings =
      "components": [],
      "hidden": [],
      "targets": {}

    componentManager.initialize {componentSettings: componentSettings}

    it '', ->

