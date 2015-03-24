(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  (function(root, factory) {
    var Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore'], function(Backbone, _) {
        return factory(root, Backbone, _);
      });
      console.log('amd');
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      console.log('commonjs');
      module.exports = factory(root, Backbone, _);
    } else {
      console.log('global');
      root.Vigor = factory(root, root.Backbone, root._);
    }
  })(this, function(root, Backbone, _) {
    var ComponentDefinitionModel, ComponentDefinitionsCollection, Vigor;
    Vigor = Backbone.Vigor = {};
    Vigor.extend = Backbone.Model.extend;
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.defaults = {
        id: void 0,
        urlPattern: void 0,
        filter: void 0,
        path: void 0,
        target: void 0
      };

      return ComponentDefinitionModel;

    })(Backbone.Model);
    ComponentDefinitionsCollection = (function(superClass) {
      extend(ComponentDefinitionsCollection, superClass);

      function ComponentDefinitionsCollection() {
        return ComponentDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionsCollection.prototype.model = ComponentDefinitionModel;

      ComponentDefinitionsCollection.prototype.initialize = function() {
        return console.log('im ComponentDefinitionsCollection');
      };

      return ComponentDefinitionsCollection;

    })(Backbone.Collection);
    (function() {
      var componentDefinitionsCollection, componentManager;
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      componentManager = {
        registerComponents: function(componentDefinitions) {
          var componentDefinition, i, len, results;
          results = [];
          for (i = 0, len = componentDefinitions.length; i < len; i++) {
            componentDefinition = componentDefinitions[i];
            results.push(this.registerComponent(componentDefinition));
          }
          return results;
        },
        registerComponent: function(componentDefinition) {
          return componentDefinitionsCollection.add(componentDefinition);
        },
        renderComponents: function() {}
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
