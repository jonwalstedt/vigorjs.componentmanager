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
    var ComponentDefinitionModel, ComponentDefinitionsCollection, FilterModel, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, Vigor, router;
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
    FilterModel = (function(superClass) {
      extend(FilterModel, superClass);

      function FilterModel() {
        return FilterModel.__super__.constructor.apply(this, arguments);
      }

      FilterModel.prototype.defaults = {
        url: void 0,
        filterString: void 0
      };

      return FilterModel;

    })(Backbone.Model);
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
        conditions: void 0,
        maxShowCount: 0
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

      ComponentDefinitionsCollection.prototype.getByComponentId = function(componentId) {
        var componentDefinition;
        componentDefinition = this.findWhere({
          componentId: componentId
        });
        if (!componentDefinition) {
          throw "Unknown componentId: " + componentId;
        }
        return componentDefinition;
      };

      return ComponentDefinitionsCollection;

    })(Backbone.Collection);
    InstanceDefinitionModel = (function(superClass) {
      extend(InstanceDefinitionModel, superClass);

      function InstanceDefinitionModel() {
        return InstanceDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionModel.prototype.defaults = {
        componentId: void 0,
        filter: void 0,
        urlPattern: void 0,
        args: void 0,
        order: void 0,
        targetName: void 0,
        showCount: 0
      };

      return InstanceDefinitionModel;

    })(Backbone.Model);
    router = new Router();
    InstanceDefinitionsCollection = (function(superClass) {
      var TARGET_PREFIX;

      extend(InstanceDefinitionsCollection, superClass);

      function InstanceDefinitionsCollection() {
        return InstanceDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      TARGET_PREFIX = 'component-area';

      InstanceDefinitionsCollection.prototype.model = InstanceDefinitionModel;

      InstanceDefinitionsCollection.prototype.parse = function(response, options) {
        var i, instanceDefinition, instanceDefinitions, instanceDefinitionsArray, len, targetName;
        instanceDefinitionsArray = [];
        for (targetName in response) {
          instanceDefinitions = response[targetName];
          for (i = 0, len = instanceDefinitions.length; i < len; i++) {
            instanceDefinition = instanceDefinitions[i];
            instanceDefinition.targetName = TARGET_PREFIX + "-" + targetName;
            instanceDefinitionsArray.push(instanceDefinition);
          }
        }
        return instanceDefinitionsArray;
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinition = function(filterOptions) {
        var instanceDefinitions;
        instanceDefinitions = this.models;
        if (filterOptions.route) {
          instanceDefinitions = this.filterInstanceDefinitionsByUrl(instanceDefinitions, filterOptions.route);
        }
        return instanceDefinitions;
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinitionsByUrl = function(route) {
        return this.filterInstanceDefinitionsByUrl(this.models, route);
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByUrl = function(instanceDefinitions, route) {
        instanceDefinitions = _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinitionModel) {
            var routeRegEx, urlPattern;
            urlPattern = instanceDefinitionModel.get('urlPattern');
            if (urlPattern) {
              routeRegEx = router._routeToRegExp(urlPattern);
              return routeRegEx.test(route);
            }
          };
        })(this));
        return instanceDefinitions;
      };

      return InstanceDefinitionsCollection;

    })(Backbone.Collection);
    (function() {
      var _geComponentInstances, _getClass, _onComponentAdded, _onComponentRemoved, _parseComponentSettings, _registerComponents, _registerInstanceDefinitons, _updateActiveComponents, activeComponents, componentDefinitionsCollection, componentManager, filterModel, instanceDefinitionsCollection;
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      instanceDefinitionsCollection = new InstanceDefinitionsCollection();
      activeComponents = new Backbone.Collection();
      filterModel = new FilterModel();
      componentManager = {
        initialize: function(settings) {
          if (settings.componentSettings) {
            _parseComponentSettings(settings.componentSettings);
          }
          filterModel.on('change', _updateActiveComponents);
          componentDefinitionsCollection.on('change', _updateActiveComponents);
          instanceDefinitionsCollection.on('change', _updateActiveComponents);
          activeComponents.on('add', _onComponentAdded);
          activeComponents.on('remove', _onComponentRemoved);
          return this;
        },
        update: function(filterOptions) {
          filterModel.set(filterOptions);
          return this;
        }
      };
      _onComponentAdded = function(model) {
        var $target, instance, order;
        $target = $("." + (model.get('target')));
        order = model.get('order');
        instance = model.get('instance');
        instance.render();
        if (order) {
          if (order === 'top') {
            return $target.prepend(instance.$el);
          } else if (order === 'bottom') {
            return $target.append(instance.$el);
          } else {
            return $target.append(instance.$el);
          }
        } else {
          return $target.append(instance.$el);
        }
      };
      _onComponentRemoved = function(model) {
        var instance;
        instance = model.get('instance');
        return instance.dispose();
      };
      _updateActiveComponents = function() {
        var componentInstances, filterOptions;
        filterOptions = filterModel.toJSON();
        componentInstances = _geComponentInstances(filterOptions);
        return activeComponents.set(componentInstances);
      };
      _geComponentInstances = function(filterOptions) {
        var componentClass, componentDefinition, filter, i, instance, instanceDefinition, instanceDefinitions, instances, isFilteredOut, len, maxShowCount, obj, showCount, urlParams;
        instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinition(filterOptions);
        instances = [];
        for (i = 0, len = instanceDefinitions.length; i < len; i++) {
          instanceDefinition = instanceDefinitions[i];
          filter = instanceDefinition.get('filter');
          componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
          showCount = instanceDefinition.get('showCount');
          maxShowCount = componentDefinition.get('maxShowCount');
          isFilteredOut = false;
          componentClass = _getClass(componentDefinition.get('src'));
          urlParams = router.getArguments(instanceDefinition.get('urlPattern'), filterOptions.route);
          instance = new componentClass({
            urlParams: urlParams,
            args: instanceDefinition.get('args')
          });
          obj = {
            instanceDefinitionId: instanceDefinition.cid,
            instance: instance,
            target: instanceDefinition.get('targetName'),
            order: instanceDefinition.get('order')
          };
          if (filter && filterOptions.filterString) {
            isFilteredOut = !filterOptions.filterString.match(new RegExp(filter));
          } else {
            isFilteredOut = false;
          }
          if (!isFilteredOut) {
            if (maxShowCount) {
              if (showCount < maxShowCount) {
                instanceDefinition.set('showCount', showCount++);
                instances.push(obj);
              }
            } else {
              instanceDefinition.set('showCount', showCount++);
              instances.push(obj);
            }
          }
        }
        return instances;
      };
      _getClass = function(src) {
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
        if (typeof componentClass !== "function") {
          throw "No constructor function found for " + src;
        }
        return componentClass;
      };
      _parseComponentSettings = function(componentSettings) {
        var componentsDefinitions, hidden, instanceDefinitions;
        componentsDefinitions = componentSettings.components || componentSettings.widgets;
        instanceDefinitions = componentSettings.layouts || componentSettings.targets;
        hidden = componentSettings.hidden;
        _registerComponents(componentsDefinitions);
        return _registerInstanceDefinitons(instanceDefinitions);
      };
      _registerComponents = function(componentDefinitions) {
        return componentDefinitionsCollection.set(componentDefinitions, {
          validate: true,
          parse: true
        });
      };
      _registerInstanceDefinitons = function(instanceDefinitions) {
        instanceDefinitionsCollection.set(instanceDefinitions, {
          validate: true,
          parse: true
        });
        return console.log(instanceDefinitionsCollection);
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
