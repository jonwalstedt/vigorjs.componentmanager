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
    var ComponentDefinitionModel, ComponentDefinitionsCollection, LayoutCollection, LayoutModel, Router, Vigor, router;
    Vigor = Backbone.Vigor = {};
    Vigor.extend = Backbone.Model.extend;
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(route, fragment) {
        var args;
        if (!_.isRegExp(route)) {
          route = this._routeToRegExp(route);
        }
        args = this._extractParameters(route, fragment);
        return _.compact(args);
      };

      return Router;

    })(Backbone.Router);
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.defaults = {
        componentId: void 0,
        src: void 0,
        showcount: void 0,
        height: void 0,
        args: void 0,
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
        if (!_.isString(attrs.src)) {
          throw 'src should be a string';
        }
        if (!/^.*[^ ].*$/.test(attrs.src)) {
          throw 'src can not be an empty string';
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
        urlPattern: void 0,
        args: void 0
      };

      return LayoutModel;

    })(Backbone.Model);
    router = new Router();
    LayoutCollection = (function(superClass) {
      var TARGET_PREFIX;

      extend(LayoutCollection, superClass);

      function LayoutCollection() {
        return LayoutCollection.__super__.constructor.apply(this, arguments);
      }

      TARGET_PREFIX = 'component-area';

      LayoutCollection.prototype.model = LayoutModel;

      LayoutCollection.prototype.parse = function(response, options) {
        var i, layout, layouts, layoutsArray, len, targetName;
        layoutsArray = [];
        for (targetName in response) {
          layouts = response[targetName];
          for (i = 0, len = layouts.length; i < len; i++) {
            layout = layouts[i];
            layout.targetName = TARGET_PREFIX + "-" + targetName;
            layoutsArray.push(layout);
          }
        }
        return layoutsArray;
      };

      LayoutCollection.prototype.getComponents = function(filterOptions) {
        var components;
        components = this.models;
        if (filterOptions.route) {
          components = this.filterComponentsByUrl(components, filterOptions.route);
        }
        return components;
      };

      LayoutCollection.prototype.getComponentsByUrl = function(route) {
        return this.filterComponentsByUrl(this.models, route);
      };

      LayoutCollection.prototype.filterComponentsByUrl = function(components, route) {
        components = _.filter(components, (function(_this) {
          return function(component) {
            var routeRegEx, urlPattern;
            urlPattern = component.get('urlPattern');
            if (urlPattern) {
              routeRegEx = router._routeToRegExp(component.get('urlPattern'));
              return routeRegEx.test(route);
            }
          };
        })(this));
        return components;
      };

      return LayoutCollection;

    })(Backbone.Collection);
    (function() {
      var activeComponents, componentDefinitionsCollection, componentManager, layoutsCollection;
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      layoutsCollection = new LayoutCollection();
      activeComponents = new Backbone.Collection();
      componentManager = {
        initialize: function(settings) {
          if (settings.componentSettings) {
            return this._parseComponentSettings(settings.componentSettings);
          }
        },
        registerComponents: function(componentDefinitions) {
          return componentDefinitionsCollection.set(componentDefinitions, {
            validate: true,
            parse: true
          });
        },
        registerLayouts: function(layouts) {
          layoutsCollection.set(layouts, {
            validate: true,
            parse: true
          });
          return console.log(layoutsCollection);
        },
        renderComponents: function(filterOptions) {
          var components;
          components = this._geComponentInstances(filterOptions);
          return console.log('componentInstances', components);
        },
        _geComponentInstances: function(filterOptions) {
          var component, componentClass, componentDefinition, components, i, instances, len, urlParams;
          components = layoutsCollection.getComponents(filterOptions);
          instances = [];
          for (i = 0, len = components.length; i < len; i++) {
            component = components[i];
            console.log('component: ', component);
            componentDefinition = componentDefinitionsCollection.findWhere({
              componentId: component.get('componentId')
            });
            componentClass = this._getClass(componentDefinition.get('src'));
            urlParams = router.getArguments(component.get('urlPattern'), filterOptions.route);
            console.log(componentClass, urlParams);
          }
        },
        _getClass: function(src) {
          var componentClass, i, len, obj, part, srcObjParts;
          if (typeof require === "function") {
            console.log('require stuff');
            componentClass = require(src);
          } else {
            obj = window;
            srcObjParts = src.split('.');
            for (i = 0, len = srcObjParts.length; i < len; i++) {
              part = srcObjParts[i];
              obj = obj[part];
            }
            componentClass = obj;
          }
          return componentClass;
        },
        _parseComponentSettings: function(componentSettings) {
          var componentsDefinitions, hidden, layouts;
          componentsDefinitions = componentSettings.components || componentSettings.widgets;
          layouts = componentSettings.layouts || componentSettings.targets;
          hidden = componentSettings.hidden;
          this.registerComponents(componentsDefinitions);
          return this.registerLayouts(layouts);
        }
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
