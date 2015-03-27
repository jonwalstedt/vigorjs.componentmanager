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
    var ComponentDefinitionModel, ComponentDefinitionsCollection, LayoutModel, TargetModel, TargetsCollection, Vigor;
    Vigor = Backbone.Vigor = {};
    Vigor.extend = Backbone.Model.extend;
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.defaults = {
        id: void 0,
        source: void 0,
        attributes: void 0
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
        return ComponentDefinitionsCollection.__super__.initialize.apply(this, arguments);
      };

      ComponentDefinitionsCollection.prototype.parse = function(response, options) {
        console.log('ComponentDefinitionsCollection:parse', response);
        return response;
      };

      return ComponentDefinitionsCollection;

    })(Backbone.Collection);
    LayoutModel = (function(superClass) {
      extend(LayoutModel, superClass);

      function LayoutModel() {
        return LayoutModel.__super__.constructor.apply(this, arguments);
      }

      LayoutModel.prototype.defaults = {
        args: void 0,
        order: void 0,
        filter: void 0,
        urlPattern: void 0,
        componentDefinitionId: void 0
      };

      return LayoutModel;

    })(Backbone.Model);
    TargetModel = (function(superClass) {
      extend(TargetModel, superClass);

      function TargetModel() {
        return TargetModel.__super__.constructor.apply(this, arguments);
      }

      TargetModel.prototype.defaults = {
        targetName: void 0,
        layoutsArray: []
      };

      return TargetModel;

    })(Backbone.Model);
    TargetsCollection = (function(superClass) {
      extend(TargetsCollection, superClass);

      function TargetsCollection() {
        return TargetsCollection.__super__.constructor.apply(this, arguments);
      }

      TargetsCollection.prototype.model = TargetModel;

      TargetsCollection.prototype.initialize = function() {
        return TargetsCollection.__super__.initialize.apply(this, arguments);
      };

      TargetsCollection.prototype.parse = function(response, options) {
        console.log('TargetsCollection:parse', response);
        return response;
      };

      return TargetsCollection;

    })(Backbone.Collection);
    (function() {
      var componentDefinitionsCollection, componentManager;
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      componentManager = {
        registerComponents: function(componentDefinitions) {
          return componentDefinitionsCollection.set(componentDefinitions);
        },
        renderComponents: function() {}
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
