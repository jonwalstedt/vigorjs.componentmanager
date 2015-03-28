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
        componentId: void 0,
        src: void 0,
        height: void 0,
        args: void 0,
        showcount: void 0,
        conditions: void 0
      };

      ComponentDefinitionModel.prototype.validate = function(attrs, options) {
        if (!attrs.componentId) {
          throw 'componentId cant be undefined';
        }
        if (typeof attrs.componentId !== 'string') {
          throw 'componentId should be a string';
        }
        if (!/^.*[^ ].*$/.test(attrs.componentId)) {
          throw 'componentId can not be an empty string';
        }
        if (!attrs.src) {
          throw 'src should be a url or classname';
        }
      };

      return ComponentDefinitionModel;

    })(Backbone.Model);
    ComponentDefinitionsCollection = (function(superClass) {
      extend(ComponentDefinitionsCollection, superClass);

      function ComponentDefinitionsCollection() {
        return ComponentDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionsCollection.prototype.model = ComponentDefinitionModel;

      return ComponentDefinitionsCollection;

    })(Backbone.Collection);
    LayoutModel = (function(superClass) {
      extend(LayoutModel, superClass);

      function LayoutModel() {
        return LayoutModel.__super__.constructor.apply(this, arguments);
      }

      LayoutModel.prototype.defaults = {
        componentId: void 0,
        order: void 0,
        filter: void 0,
        args: void 0
      };

      LayoutModel.prototype.validate = function(attrs, options) {
        return console.log('TargetsCollection:validate', attrs);
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

      TargetModel.prototype.validate = function(attrs, options) {
        if (!attrs.targetName) {
          throw 'targetName cant be undefined';
        }
        if (typeof attrs.targetName !== 'string') {
          throw 'targetName should be a string';
        }
        if (!/^.*[^ ].*$/.test(attrs.targetName)) {
          throw 'targetName can not be an empty string';
        }
        if (!attrs.layoutsArray) {
          throw 'layoutsArray cant be undefined';
        }
        if (!_.isArray(attrs.layoutsArray)) {
          throw 'layoutsArray must be an array';
        }
      };

      return TargetModel;

    })(Backbone.Model);
    TargetsCollection = (function(superClass) {
      var TARGET_PREFIX;

      extend(TargetsCollection, superClass);

      function TargetsCollection() {
        return TargetsCollection.__super__.constructor.apply(this, arguments);
      }

      TARGET_PREFIX = 'component-area';

      TargetsCollection.prototype.model = TargetModel;

      TargetsCollection.prototype.parse = function(response, options) {
        var i, layout, layoutModel, layouts, layoutsArray, len, targetName, targets;
        targets = [];
        for (targetName in response) {
          layouts = response[targetName];
          layoutsArray = [];
          for (i = 0, len = layouts.length; i < len; i++) {
            layout = layouts[i];
            layoutModel = new LayoutModel(layout);
            layoutsArray.push(layoutModel);
          }
          targets.push({
            targetName: TARGET_PREFIX + "-" + targetName,
            layoutsArray: layoutsArray
          });
        }
        return targets;
      };

      return TargetsCollection;

    })(Backbone.Collection);
    (function() {
      var componentDefinitionsCollection, componentManager, targetsCollection;
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      targetsCollection = new TargetsCollection();
      componentManager = {
        initialize: function(settings) {
          if (settings.componentSettings) {
            return this.parseComponentSettings(settings.componentSettings);
          }
        },
        parseComponentSettings: function(componentSettings) {
          var componentsDefinitions, hidden, targets;
          componentsDefinitions = componentSettings.components || componentSettings.widgets;
          targets = componentSettings.targets;
          hidden = componentSettings.hidden;
          this.registerComponents(componentsDefinitions);
          return this.registerTargets(targets);
        },
        registerComponents: function(componentDefinitions) {
          return componentDefinitionsCollection.set(componentDefinitions, {
            validate: true,
            parse: true
          });
        },
        registerTargets: function(targets) {
          return targetsCollection.set(targets, {
            validate: true,
            parse: true
          });
        }
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
