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
      var COMPONENT_CLASS, _addInstanceToDom, _getClass, _getComponentInstances, _onComponentAdded, _onComponentRemoved, _parseComponentSettings, _previousElement, _registerComponents, _registerInstanceDefinitons, _updateActiveComponents, activeComponents, componentDefinitionsCollection, componentManager, filterModel, instanceDefinitionsCollection;
      COMPONENT_CLASS = 'vigorjs-component';
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
        refresh: function(filterOptions) {
          filterModel.set(filterOptions);
          return this;
        },
        addComponentDefinition: function(componentDefinition) {
          componentDefinitionsCollection.set(componentDefinition, {
            validate: true,
            parse: true,
            remove: false
          });
          return this;
        },
        removeComponentDefinition: function(componentDefinitionId) {
          instanceDefinitionsCollection.remove(componentDefinitionId);
          return this;
        },
        addInstance: function(instanceDefinition) {
          instanceDefinitionsCollection.set(instanceDefinition, {
            validate: true,
            parse: true,
            remove: false
          });
          return this;
        },
        removeInstance: function(instancecId) {
          instanceDefinitionsCollection.remove(instancecId);
          return this;
        },
        clear: function() {
          componentDefinitionsCollection.reset();
          instanceDefinitionsCollection.reset();
          activeComponents.reset();
          return filterModel.clear();
        },
        dispose: function() {
          this.clear();
          filterModel.off();
          activeComponents.off();
          componentDefinitionsCollection.off();
          filterModel = void 0;
          activeComponents = void 0;
          return componentDefinitionsCollection = void 0;
        },
        getComponentInstances: function(filterOptions) {
          return _getComponentInstances(filterOptions);
        }
      };
      _previousElement = function($el, order) {
        if (order == null) {
          order = 0;
        }
        if ($el.length > 0) {
          if ($el.data('order') < order) {
            return $el;
          } else {
            return _previousElement($el.prev(), order);
          }
        }
      };
      _updateActiveComponents = function() {
        var componentInstances, filterOptions;
        filterOptions = filterModel.toJSON();
        componentInstances = _getComponentInstances(filterOptions);
        return activeComponents.set(componentInstances);
      };
      _getComponentInstances = function(filterOptions) {
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
          instance.$el.addClass(COMPONENT_CLASS);
          obj = {
            instance: instance,
            instanceDefinitionId: instanceDefinition.get('id') || instanceDefinition.cid,
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
        var componentDefinitions, hidden, instanceDefinitions;
        componentDefinitions = componentSettings.components || componentSettings.widgets || componentSettings.componentDefinitions;
        instanceDefinitions = componentSettings.layoutsArray || componentSettings.targets || componentSettings.instanceDefinitions;
        hidden = componentSettings.hidden;
        _registerComponents(componentDefinitions);
        return _registerInstanceDefinitons(instanceDefinitions);
      };
      _registerComponents = function(componentDefinitions) {
        return componentDefinitionsCollection.set(componentDefinitions, {
          validate: true,
          parse: true
        });
      };
      _registerInstanceDefinitons = function(instanceDefinitions) {
        return instanceDefinitionsCollection.set(instanceDefinitions, {
          validate: true,
          parse: true
        });
      };
      _addInstanceToDom = function(model, render) {
        var $previousElement, $target, instance, order;
        if (render == null) {
          render = true;
        }
        $target = $("." + (model.get('target')));
        order = model.get('order');
        instance = model.get('instance');
        if (render) {
          instance.render();
        }
        if (order) {
          if (order === 'top') {
            instance.$el.data('order', 0);
            return $target.prepend(instance.$el);
          } else if (order === 'bottom') {
            instance.$el.data('order', 999);
            return $target.append(instance.$el);
          } else {
            $previousElement = _previousElement($target.children().last(), order);
            instance.$el.data('order', order);
            instance.$el.attr('data-order', order);
            if (!$previousElement) {
              return $target.prepend(instance.$el);
            } else {
              return instance.$el.insertAfter($previousElement);
            }
          }
        } else {
          return $target.append(instance.$el);
        }
      };
      _onComponentAdded = function(model) {
        return _addInstanceToDom(model);
      };
      _onComponentRemoved = function(model) {
        var instance;
        instance = model.get('instance');
        return instance.dispose();
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
