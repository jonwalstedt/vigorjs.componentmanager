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

    it 'should extend underscore events', ->
    it 'should call registerConditions if being passed conditions in componentSettings', ->

  describe 'updateSettings', ->
    it 'it should update componentClassName if being passed a new componentClassName', ->
    it 'it should update the target prefix if being passed a new prefix', ->

  describe 'refresh', ->
    # all different variations of filters should be tested here, only way to test
    # is to check agianst dom
    it '', ->

  describe 'serialize', ->
    it 'should serialize the data used by the componentManager into a format that it can read', ->

  describe 'addComponent', ->
    it 'should validate incoming component data', ->
    it 'should parse incoming component data', ->
    it 'should store incoming component data', ->
    it 'should not remove old components', ->

  describe 'updateComponent', ->
    it 'should validate incomming component data'
    it 'should update a specific component with new data', ->

  describe 'removeComponent', ->
    it 'should remove a specific component', ->

  describe 'getComponentById', ->
    it 'should get a JSON representation of the data for a specific component', ->

  describe 'getComponents', ->
    it 'shuld return an array of all registered components', ->

  describe 'addInstance', ->
    it 'should validate incoming instance data', ->
    it 'should parse incoming instance data', ->
    it 'should store incoming instance data', ->
    it 'should not remove old instances', ->

  describe 'updateInstance', ->
    it 'should validate incomming instance data'
    it 'should update a specific instance with new data', ->

  describe 'removeInstance', ->
    it 'should remove a specific instance', ->

  describe 'getInstanceById', ->
    it 'should get a JSON representation of the data for one specific instance', ->

  describe 'getInstances', ->
    it 'should return all instances (even those not currently active)', ->

  describe 'getActiveInstances', ->
    it 'should return all active instances', ->

  describe 'getTargetPrefix', ->
    it '', ->

  describe 'registerConditions', ->
    it '', ->

  describe 'getConditions', ->
    it '', ->

  describe 'clear', ->
    it '', ->

  describe 'dispose', ->
    it '', ->

