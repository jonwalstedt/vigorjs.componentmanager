assert = require 'assert'
sinon = require 'sinon'

componentManager = require('../../dist/backbone.vigor.componentmanager').componentManager

describe 'A componentManager', ->

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

  describe 'updateInstances', ->
    it 'should validate incomming instance data'
    it 'should update one or multiple instances with new data', ->

  describe 'removeInstance', ->
    it 'should remove a specific instance', ->

  describe 'getInstanceById', ->
    it 'should get a JSON representation of the data for one specific instance', ->

  describe 'getInstances', ->
    it 'should return all instances (even those not currently active)', ->

  describe 'getActiveInstances', ->
    it 'should return all active instances', ->

  describe 'getTargetPrefix', ->
    it 'should return a specified prefix or the default prefix', ->

  describe 'registerConditions', ->
    it 'should register new conditions', ->
    it 'should not remove old conditions', ->
    it 'should update existing conditions', ->

  describe 'getConditions', ->
    it 'return current conditions', ->

  describe 'clear', ->
    it 'should remove all components', ->
    it 'should remove all instances', ->
    it 'should remove all activeComponents', ->
    it 'should remove all filters', ->
    it 'should remove all conditions', ->

  describe 'dispose', ->
    it 'should call clear', ->

