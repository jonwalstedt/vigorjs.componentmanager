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

  Vigor = Backbone.Vigor = {}

  Vigor.extend = Backbone.Model.extend

  # COMMON
  #= include ./router/Router.coffee
  #= include ./filter/FilterModel.coffee
  #= include ./component-definitions/ComponentDefinitionModel.coffee
  #= include ./component-definitions/ComponentDefinitionsCollection.coffee
  #= include ./targets/InstanceDefinitionModel.coffee
  #= include ./targets/InstanceDefinitionsCollection.coffee
  #= include ./index.coffee

  return Vigor
