((root, factory) ->
  if typeof define is "function" and define.amd

    # AMD. Register as an anonymous module.
    define ['backbone', 'underscore'], (Backbone, _) ->
      return factory(root, Backbone, _)
    console.log 'amd'

  else if typeof exports is "object"
    Backbone = require 'backbone'
    _ = require 'underscore'
    # Node. Does not work with strict CommonJS, but
    # only CommonJS-like environments that support module.exports,
    # like Node.
    console.log 'commonjs'
    module.exports = factory(root, Backbone, _)
  else

    console.log 'global'
    # Browser globals (root is window)
    root.Vigor = factory(root, root.Backbone, root._)
  return

) @, (root, Backbone, _) ->

  Vigor = Backbone.Vigor = root.Vigor or {}

  Vigor.extend = Vigor.extend or Backbone.Model.extend

  # COMMON
  #= include ./component-manager/router/Router.coffee
  #= include ./component-manager/filter/FilterModel.coffee
  #= include ./component-manager/iframe-component/IframeComponent.coffee
  #= include ./component-manager/component-definitions/ComponentDefinitionModel.coffee
  #= include ./component-manager/component-definitions/ComponentDefinitionsCollection.coffee
  #= include ./component-manager/active-components/ActiveComponentsCollection.coffee
  #= include ./component-manager/targets/InstanceDefinitionModel.coffee
  #= include ./component-manager/targets/InstanceDefinitionsCollection.coffee
  #= include ./component-manager/index.coffee

  return Vigor
