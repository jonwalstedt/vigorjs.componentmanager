((root, factory) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ['backbone', 'underscore', 'jquery'], (Backbone, _, $) ->
      return factory(root, Backbone, _, $)

  else if typeof exports is "object"
    Backbone = require 'backbone'
    _ = require 'underscore'
    $ = require 'jquery'
    # Node. Does not work with strict CommonJS, but
    # only CommonJS-like environments that support module.exports,
    # like Node.
    module.exports = factory(root, Backbone, _, $)
  else
    # Browser globals (root is window)
    root.Vigor = factory(root, root.Backbone, root._, root.$)
  return

) @, (root, Backbone, _, $) ->

  Vigor = Backbone.Vigor = root.Vigor or {}

  Vigor.extend = Vigor.extend or Backbone.Model.extend

  # COMMON
  #= include ./component-manager/BaseCollection.coffee
  #= include ./component-manager/BaseModel.coffee
  #= include ./component-manager/router/Router.coffee
  #= include ./component-manager/filter/FilterModel.coffee
  #= include ./component-manager/iframe-component/IframeComponent.coffee
  #= include ./component-manager/component-definitions/ComponentDefinitionModel.coffee
  #= include ./component-manager/component-definitions/ComponentDefinitionsCollection.coffee
  #= include ./component-manager/instance-definitions/ActiveInstanceDefinitionModel.coffee
  #= include ./component-manager/instance-definitions/InstanceDefinitionModel.coffee
  #= include ./component-manager/instance-definitions/BaseInstanceCollection.coffee
  #= include ./component-manager/instance-definitions/InstanceDefinitionsCollection.coffee
  #= include ./component-manager/instance-definitions/ActiveInstancesCollection.coffee
  #= include ./component-manager/index.coffee

  Vigor.componentManager = new Vigor.ComponentManager()

  return Vigor
