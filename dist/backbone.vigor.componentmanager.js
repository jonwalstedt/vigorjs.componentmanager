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
    var ActiveInstancesCollection, ComponentDefinitionModel, ComponentDefinitionsCollection, FilterModel, IframeComponent, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, Vigor, router;
    Vigor = Backbone.Vigor = root.Vigor || {};
    Vigor.extend = Vigor.extend || Backbone.Model.extend;
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(routes, fragment) {
        var args, j, len, route;
        if (_.isArray(routes)) {
          args = [];
          for (j = 0, len = routes.length; j < len; j++) {
            route = routes[j];
            args = this._getArgumentsFromRoute(route, fragment);
          }
          return args;
        } else {
          return this._getArgumentsFromRoute(routes, fragment);
        }
      };

      Router.prototype._getArgumentsFromRoute = function(route, fragment) {
        var args, origRoute;
        origRoute = route;
        if (!_.isRegExp(route)) {
          route = this._routeToRegExp(route);
        }
        args = [];
        if (route.exec(fragment)) {
          args = _.compact(this._extractParameters(route, fragment));
        }
        args = this._getParamsObject(origRoute, args);
        return args;
      };

      Router.prototype._getParamsObject = function(route, args) {
        var namedParam, names, optionalParam, optionalParams, params, splatParam, splats, storeNames;
        optionalParam = /\((.*?)\)/g;
        namedParam = /(\(\?)?:\w+/g;
        splatParam = /\*\w+/g;
        params = {};
        optionalParams = route.match(new RegExp(optionalParam));
        names = route.match(new RegExp(namedParam));
        splats = route.match(new RegExp(splatParam));
        storeNames = function(matches, args) {
          var i, j, len, name, results;
          results = [];
          for (i = j = 0, len = matches.length; j < len; i = ++j) {
            name = matches[i];
            name = name.replace(':', '').replace('(', '').replace(')', '').replace('*', '');
            results.push(params[name] = args[i]);
          }
          return results;
        };
        if (optionalParams) {
          storeNames(optionalParams, args);
        }
        if (names) {
          storeNames(names, args);
        }
        if (splats) {
          storeNames(splats, args);
        }
        return params;
      };

      return Router;

    })(Backbone.Router);
    FilterModel = (function(superClass) {
      extend(FilterModel, superClass);

      function FilterModel() {
        return FilterModel.__super__.constructor.apply(this, arguments);
      }

      FilterModel.prototype.defaults = {
        route: void 0,
        filterString: void 0
      };

      return FilterModel;

    })(Backbone.Model);
    IframeComponent = (function(superClass) {
      extend(IframeComponent, superClass);

      IframeComponent.prototype.tagName = 'iframe';

      IframeComponent.prototype.className = 'vigor-component--iframe';

      IframeComponent.prototype.attributes = {
        seamless: 'seamless',
        scrolling: false,
        border: 0,
        frameborder: 0
      };

      IframeComponent.prototype.src = void 0;

      function IframeComponent(attrs) {
        _.extend(this.attributes, attrs.iframeAttributes);
        IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.initialize = function(attrs) {
        this.src = attrs.src;
        return this.$el.on('load', this.onIframeLoaded);
      };

      IframeComponent.prototype.render = function() {
        return this.$el.attr('src', this.src);
      };

      IframeComponent.prototype.dispose = function() {
        this.$el.off('load', this.onIframeLoaded);
        return this.remove();
      };

      IframeComponent.prototype.onIframeLoaded = function(event) {};

      return IframeComponent;

    })(Backbone.View);
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.defaults = {
        id: void 0,
        src: void 0,
        showcount: void 0,
        height: void 0,
        args: void 0,
        conditions: void 0,
        instance: void 0,
        maxShowCount: 0
      };

      ComponentDefinitionModel.prototype.validate = function(attrs, options) {
        var isValidType;
        if (!attrs.id) {
          throw 'id cant be undefined';
        }
        if (typeof attrs.id !== 'string') {
          throw 'id should be a string';
        }
        if (/^\s+$/g.test(attrs.id)) {
          throw 'id can not be an empty string';
        }
        if (!attrs.src) {
          throw 'src cant be undefined';
        }
        isValidType = _.isString(attrs.src) || _.isFunction(attrs.src);
        if (!isValidType) {
          throw 'src should be a string or a constructor function';
        }
        if (_.isString(attrs.src) && /^\s+$/g.test(attrs.src)) {
          throw 'src can not be an empty string';
        }
      };

      ComponentDefinitionModel.prototype.getClass = function() {
        var componentClass, j, len, obj, part, src, srcObjParts;
        src = this.get('src');
        if (_.isString(src) && this._isUrl(src)) {
          componentClass = IframeComponent;
        } else if (_.isString(src)) {
          obj = window;
          srcObjParts = src.split('.');
          for (j = 0, len = srcObjParts.length; j < len; j++) {
            part = srcObjParts[j];
            obj = obj[part];
          }
          componentClass = obj;
        } else if (_.isFunction(src)) {
          componentClass = src;
        }
        if (!_.isFunction(componentClass)) {
          throw "No constructor function found for " + src;
        }
        return componentClass;
      };

      ComponentDefinitionModel.prototype._isUrl = function(string) {
        var urlRegEx;
        urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
        return urlRegEx.test(string);
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
    InstanceDefinitionModel = (function(superClass) {
      extend(InstanceDefinitionModel, superClass);

      function InstanceDefinitionModel() {
        return InstanceDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionModel.prototype.defaults = {
        id: void 0,
        componentId: void 0,
        filter: void 0,
        conditions: void 0,
        args: void 0,
        order: void 0,
        targetName: void 0,
        instance: void 0,
        showCount: 0,
        urlPattern: void 0,
        urlParams: void 0,
        urlParamsModel: void 0,
        reInstantiateOnUrlParamChange: false
      };

      InstanceDefinitionModel.prototype.isAttached = function() {
        var attached, instance;
        instance = this.get('instance');
        attached = false;
        if (instance) {
          attached = $.contains(document.body, instance.el);
        }
        return attached;
      };

      InstanceDefinitionModel.prototype.dispose = function() {
        var instance;
        instance = this.get('instance');
        if (instance) {
          instance.dispose();
          return this.clear();
        }
      };

      InstanceDefinitionModel.prototype.validate = function(attrs, options) {
        if (!attrs.id) {
          throw 'id cant be undefined';
        }
        if (!_.isString(attrs.id)) {
          throw 'id should be a string';
        }
        if (!/^.*[^ ].*$/.test(attrs.id)) {
          throw 'id can not be an empty string';
        }
        if (!attrs.componentId) {
          throw 'componentId cant be undefined';
        }
        if (!_.isString(attrs.componentId)) {
          throw 'componentId should be a string';
        }
        if (!/^.*[^ ].*$/.test(attrs.componentId)) {
          throw 'componentId can not be an empty string';
        }
        if (!attrs.targetName) {
          throw 'targetName cant be undefined';
        }
      };

      InstanceDefinitionModel.prototype.incrementShowCount = function(silent) {
        var showCount;
        if (silent == null) {
          silent = true;
        }
        showCount = this.get('showCount');
        showCount++;
        return this.set({
          'showCount': showCount
        }, {
          silent: silent
        });
      };

      InstanceDefinitionModel.prototype.renderInstance = function() {
        var instance;
        instance = this.get('instance');
        if (!instance) {
          return;
        }
        if (!instance.render) {
          throw "The enstance " + (instance.get('id')) + " does not have a render method";
        }
        if ((instance.preRender != null) && _.isFunction(instance.preRender)) {
          instance.preRender();
        }
        instance.render();
        if ((instance.postrender != null) && _.isFunction(instance.postRender)) {
          return instance.postRender();
        }
      };

      InstanceDefinitionModel.prototype.disposeAndRemoveInstance = function() {
        var instance;
        instance = this.get('instance');
        instance.dispose();
        instance = void 0;
        return this.set({
          'instance': void 0
        }, {
          silent: true
        });
      };

      return InstanceDefinitionModel;

    })(Backbone.Model);
    router = new Router();
    InstanceDefinitionsCollection = (function(superClass) {
      extend(InstanceDefinitionsCollection, superClass);

      function InstanceDefinitionsCollection() {
        return InstanceDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionsCollection.prototype.targetPrefix = void 0;

      InstanceDefinitionsCollection.prototype.model = InstanceDefinitionModel;

      InstanceDefinitionsCollection.prototype.setTargetPrefix = function(targetPrefix1) {
        this.targetPrefix = targetPrefix1;
      };

      InstanceDefinitionsCollection.prototype.parse = function(response, options) {
        var i, instanceDefinition, instanceDefinitions, instanceDefinitionsArray, j, k, len, len1, parsedResponse, targetName;
        parsedResponse = void 0;
        instanceDefinitionsArray = [];
        if (_.isObject(response) && !_.isArray(response)) {
          for (targetName in response) {
            instanceDefinitions = response[targetName];
            if (_.isArray(instanceDefinitions)) {
              for (j = 0, len = instanceDefinitions.length; j < len; j++) {
                instanceDefinition = instanceDefinitions[j];
                instanceDefinition.targetName = this.targetPrefix + "--" + targetName;
                this.parseInstanceDefinition(instanceDefinition);
                instanceDefinitionsArray.push(instanceDefinition);
              }
              parsedResponse = instanceDefinitionsArray;
            } else {
              parsedResponse = this.parseInstanceDefinition(response);
              break;
            }
          }
        } else if (_.isArray(response)) {
          for (i = k = 0, len1 = response.length; k < len1; i = ++k) {
            instanceDefinition = response[i];
            response[i] = this.parseInstanceDefinition(instanceDefinition);
          }
          parsedResponse = response;
        }
        return parsedResponse;
      };

      InstanceDefinitionsCollection.prototype.parseInstanceDefinition = function(instanceDefinition) {
        instanceDefinition.urlParamsModel = new Backbone.Model();
        if (instanceDefinition.urlPattern === 'global') {
          instanceDefinition.urlPattern = ['*notFound', '*action'];
        }
        return instanceDefinition;
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinitions = function(filterOptions) {
        var instanceDefinitions;
        instanceDefinitions = this.models;
        if (filterOptions.route || filterOptions.route === '') {
          instanceDefinitions = this.filterInstanceDefinitionsByUrl(instanceDefinitions, filterOptions.route);
          instanceDefinitions = this.addUrlParams(instanceDefinitions, filterOptions.route);
        }
        if (filterOptions.filterString) {
          instanceDefinitions = this.filterInstanceDefinitionsByString(instanceDefinitions, filterOptions.filterString);
        }
        if (filterOptions.conditions) {
          instanceDefinitions = this.filterInstanceDefinitionsByConditions(instanceDefinitions, filterOptions.conditions);
        }
        return instanceDefinitions;
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinitionsByUrl = function(route) {
        return this.filterInstanceDefinitionsByUrl(this.models, route);
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByUrl = function(instanceDefinitions, route) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinitionModel) {
            var j, len, match, pattern, routeRegEx, urlPattern;
            urlPattern = instanceDefinitionModel.get('urlPattern');
            if (urlPattern) {
              if (_.isArray(urlPattern)) {
                match = false;
                for (j = 0, len = urlPattern.length; j < len; j++) {
                  pattern = urlPattern[j];
                  routeRegEx = router._routeToRegExp(pattern);
                  match = routeRegEx.test(route);
                  if (match) {
                    return match;
                  }
                }
                return match;
              } else {
                routeRegEx = router._routeToRegExp(urlPattern);
                return routeRegEx.test(route);
              }
            }
          };
        })(this));
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByString = function(instanceDefinitions, filterString) {
        return _.filter(instanceDefinitions, function(instanceDefinitionModel) {
          var filter;
          filter = instanceDefinitionModel.get('filter');
          if (!filter) {
            return false;
          } else {
            return filterString.match(new RegExp(filter));
          }
        });
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByConditions = function(instanceDefinitions, conditions) {
        return _.filter(instanceDefinitions, function(instanceDefinitionModel) {
          var condition, instanceConditions, j, len, shouldBeIncluded;
          instanceConditions = instanceDefinitionModel.get('conditions');
          shouldBeIncluded = true;
          if (instanceConditions) {
            if (_.isArray(instanceConditions)) {
              for (j = 0, len = instanceConditions.length; j < len; j++) {
                condition = instanceConditions[j];
                if (_.isFunction(condition) && !condition()) {
                  shouldBeIncluded = false;
                  return;
                } else if (_.isString(condition)) {
                  shouldBeIncluded = conditions[condition]();
                }
              }
            } else if (_.isFunction(instanceConditions)) {
              shouldBeIncluded = instanceConditions();
            } else if (_.isString(instanceConditions)) {
              shouldBeIncluded = conditions[instanceConditions]();
            }
          }
          return shouldBeIncluded;
        });
      };

      InstanceDefinitionsCollection.prototype.addUrlParams = function(instanceDefinitions, route) {
        var instanceDefinition, j, len, urlParams, urlParamsModel;
        for (j = 0, len = instanceDefinitions.length; j < len; j++) {
          instanceDefinition = instanceDefinitions[j];
          urlParams = router.getArguments(instanceDefinition.get('urlPattern'), route);
          urlParams.route = route;
          urlParamsModel = instanceDefinition.get('urlParamsModel');
          urlParamsModel.set(urlParams);
          instanceDefinition.set({
            'urlParams': urlParams
          }, {
            silent: !instanceDefinition.get('reInstantiateOnUrlParamChange')
          });
        }
        return instanceDefinitions;
      };

      return InstanceDefinitionsCollection;

    })(Backbone.Collection);
    ActiveInstancesCollection = (function(superClass) {
      extend(ActiveInstancesCollection, superClass);

      function ActiveInstancesCollection() {
        return ActiveInstancesCollection.__super__.constructor.apply(this, arguments);
      }

      ActiveInstancesCollection.prototype.model = InstanceDefinitionModel;

      ActiveInstancesCollection.prototype.getStrays = function() {
        var strays;
        strays = _.filter(this.models, (function(_this) {
          return function(model) {
            if (model.get('instance')) {
              return !model.isAttached();
            } else {
              return false;
            }
          };
        })(this));
        return strays;
      };

      return ActiveInstancesCollection;

    })(Backbone.Collection);
    (function() {
      var $context, EVENTS, __testOnly, _addInstanceInOrder, _addInstanceToDom, _addInstanceToModel, _addListeners, _filterInstanceDefinitions, _filterInstanceDefinitionsByShowConditions, _filterInstanceDefinitionsByShowCount, _isComponentAreaEmpty, _onComponentAdded, _onComponentChange, _onComponentOrderChange, _onComponentRemoved, _onComponentTargetNameChange, _parseComponentSettings, _previousElement, _registerComponents, _registerInstanceDefinitons, _removeListeners, _tryToReAddStraysToDom, _updateActiveComponents, activeInstancesCollection, componentClassName, componentDefinitionsCollection, componentManager, conditions, filterModel, instanceDefinitionsCollection, targetPrefix;
      componentClassName = 'vigor-component';
      targetPrefix = 'component-area';
      componentDefinitionsCollection = void 0;
      instanceDefinitionsCollection = void 0;
      activeInstancesCollection = void 0;
      filterModel = void 0;
      $context = void 0;
      conditions = {};
      EVENTS = {
        ADD: 'add',
        CHANGE: 'change',
        REMOVE: 'remove',
        COMPONENT_ADD: 'component-add',
        COMPONENT_CHANGE: 'component-change',
        COMPONENT_REMOVE: 'component-remove',
        INSTANCE_ADD: 'instance-add',
        INSTANCE_CHANGE: 'instance-change',
        INSTANCE_REMOVE: 'instance-remove'
      };
      componentManager = {
        initialize: function(settings) {
          componentDefinitionsCollection = new ComponentDefinitionsCollection();
          instanceDefinitionsCollection = new InstanceDefinitionsCollection();
          activeInstancesCollection = new ActiveInstancesCollection();
          filterModel = new FilterModel();
          _.extend(this, EVENTS);
          _addListeners();
          if (settings.$context) {
            $context = settings.$context;
          } else {
            $context = $('body');
          }
          if (settings.componentSettings) {
            _parseComponentSettings(settings.componentSettings);
          }
          if (settings.componentSettings.conditions) {
            this.registerConditions(settings.componentSettings.conditions);
          }
          return this;
        },
        updateSettings: function(settings) {
          componentClassName = settings.componentClassName || componentClassName;
          targetPrefix = settings.targetPrefix || targetPrefix;
          return this;
        },
        refresh: function(filterOptions) {
          filterModel.set(filterOptions);
          return this;
        },
        serialize: function() {
          return console.log('return data in a readable format for the componentManager');
        },
        addComponent: function(componentDefinition) {
          componentDefinitionsCollection.set(componentDefinition, {
            validate: true,
            parse: true,
            remove: false
          });
          return this;
        },
        updateComponent: function(componentId, attributes) {
          var componentDefinition;
          componentDefinition = componentDefinitionsCollection.get(componentId);
          if (componentDefinition != null) {
            componentDefinition.set(attributes, {
              validate: true
            });
          }
          return this;
        },
        removeComponent: function(componentDefinitionId) {
          instanceDefinitionsCollection.remove(componentDefinitionId);
          return this;
        },
        getComponentById: function(componentId) {
          var ref;
          return (ref = componentDefinitionsCollection.get(componentId)) != null ? ref.toJSON() : void 0;
        },
        getComponents: function() {
          return componentDefinitionsCollection.toJSON();
        },
        addInstance: function(instanceDefinition) {
          instanceDefinitionsCollection.set(instanceDefinition, {
            validate: true,
            parse: true,
            remove: false
          });
          return this;
        },
        updateInstance: function(instanceId, attributes) {
          var instanceDefinition;
          instanceDefinition = instanceDefinitionsCollection.get(instanceId);
          if (instanceDefinition != null) {
            instanceDefinition.set(attributes, {
              validate: true
            });
          }
          return this;
        },
        removeInstance: function(instanceId) {
          instanceDefinitionsCollection.remove(instanceId);
          return this;
        },
        getInstanceById: function(instanceId) {
          var ref;
          return (ref = instanceDefinitionsCollection.get(instanceId)) != null ? ref.toJSON() : void 0;
        },
        getInstances: function() {
          return instanceDefinitionsCollection.toJSON();
        },
        getActiveInstances: function() {
          var instances;
          instances = _.map(activeInstancesCollection.models, function(instanceDefinition) {
            var instance;
            instance = instanceDefinition.get('instance');
            if (!instance) {
              _addInstanceToModel(instanceDefinition);
              instance = instanceDefinition.get('instance');
            }
            return instance;
          });
          return instances;
        },
        getTargetPrefix: function() {
          return targetPrefix;
        },
        registerConditions: function(conditionsToBeRegistered) {
          _.extend(conditions, conditionsToBeRegistered);
          return this;
        },
        getConditions: function() {
          return conditions;
        },
        clear: function() {
          componentDefinitionsCollection.reset();
          instanceDefinitionsCollection.reset();
          activeInstancesCollection.reset();
          filterModel.clear();
          conditions = {};
          return this;
        },
        dispose: function() {
          this.clear();
          this._removeListeners();
          filterModel = void 0;
          activeInstancesCollection = void 0;
          conditions = void 0;
          return componentDefinitionsCollection = void 0;
        }
      };
      _addListeners = function() {
        filterModel.on('add change remove', _updateActiveComponents);
        componentDefinitionsCollection.on('add change remove', _updateActiveComponents);
        instanceDefinitionsCollection.on('add change remove', _updateActiveComponents);
        activeInstancesCollection.on('add', _onComponentAdded);
        activeInstancesCollection.on('change', _onComponentChange);
        activeInstancesCollection.on('remove', _onComponentRemoved);
        activeInstancesCollection.on('change:order', _onComponentOrderChange);
        activeInstancesCollection.on('change:targetName', _onComponentTargetNameChange);
        componentDefinitionsCollection.on('add', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.COMPONENT_ADD, [model.toJSON(), collection.toJSON()]]);
        });
        componentDefinitionsCollection.on('change', function(model, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.COMPONENT_CHANGE, [model.toJSON()]]);
        });
        componentDefinitionsCollection.on('remove', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.COMPONENT_REMOVE, [model.toJSON(), collection.toJSON()]]);
        });
        instanceDefinitionsCollection.on('add', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.INSTANCE_ADD, [model.toJSON(), collection.toJSON()]]);
        });
        instanceDefinitionsCollection.on('change', function(model, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.INSTANCE_CHANGE, [model.toJSON()]]);
        });
        instanceDefinitionsCollection.on('remove', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.INSTANCE_REMOVE, [model.toJSON(), collection.toJSON()]]);
        });
        activeInstancesCollection.on('add', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.ADD, [model.toJSON(), collection.toJSON()]]);
        });
        activeInstancesCollection.on('change', function(model, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.CHANGE, [model.toJSON()]]);
        });
        return activeInstancesCollection.on('remove', function(model, collection, options) {
          return componentManager.trigger.apply(componentManager, [EVENTS.REMOVE, [model.toJSON(), collection.toJSON()]]);
        });
      };
      _removeListeners = function() {
        activeInstancesCollection.off();
        filterModel.off();
        instanceDefinitionsCollection.off();
        return componentDefinitionsCollection.off();
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
        var filterOptions, instanceDefinitions;
        filterOptions = filterModel.toJSON();
        filterOptions.conditions = conditions;
        instanceDefinitions = _filterInstanceDefinitions(filterOptions);
        activeInstancesCollection.set(instanceDefinitions);
        return _tryToReAddStraysToDom();
      };
      _filterInstanceDefinitions = function(filterOptions) {
        var instanceDefinitions;
        instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions(filterOptions);
        instanceDefinitions = _filterInstanceDefinitionsByShowCount(instanceDefinitions);
        instanceDefinitions = _filterInstanceDefinitionsByShowConditions(instanceDefinitions);
        return instanceDefinitions;
      };
      _filterInstanceDefinitionsByShowCount = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, function(instanceDefinition) {
          var componentDefinition, maxShowCount, shouldBeIncluded, showCount;
          componentDefinition = componentDefinitionsCollection.get(instanceDefinition.get('componentId'));
          showCount = instanceDefinition.get('showCount');
          maxShowCount = instanceDefinition.get('maxShowCount');
          shouldBeIncluded = true;
          if (!maxShowCount) {
            maxShowCount = componentDefinition.get('maxShowCount');
          }
          if (maxShowCount) {
            if (showCount < maxShowCount) {
              shouldBeIncluded = true;
            } else {
              shouldBeIncluded = false;
            }
          }
          return shouldBeIncluded;
        });
      };
      _filterInstanceDefinitionsByShowConditions = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, function(instanceDefinition) {
          var componentConditions, componentDefinition, condition, j, len, shouldBeIncluded;
          componentDefinition = componentDefinitionsCollection.get(instanceDefinition.get('componentId'));
          componentConditions = componentDefinition.get('conditions');
          shouldBeIncluded = true;
          if (componentConditions) {
            if (_.isArray(componentConditions)) {
              for (j = 0, len = componentConditions.length; j < len; j++) {
                condition = componentConditions[j];
                if (!conditions[condition]()) {
                  shouldBeIncluded = false;
                  return;
                }
              }
            } else if (_.isString(componentConditions)) {
              shouldBeIncluded = conditions[componentConditions]();
            }
          }
          return shouldBeIncluded;
        });
      };
      _parseComponentSettings = function(componentSettings) {
        var componentDefinitions, hidden, instanceDefinitions;
        componentDefinitions = componentSettings.components || componentSettings.widgets || componentSettings.componentDefinitions;
        instanceDefinitions = componentSettings.layoutsArray || componentSettings.targets || componentSettings.instanceDefinitions;
        if (componentSettings.settings) {
          componentManager.updateSettings(componentSettings.settings);
        }
        hidden = componentSettings.hidden;
        _registerComponents(componentDefinitions);
        return _registerInstanceDefinitons(instanceDefinitions);
      };
      _registerComponents = function(componentDefinitions) {
        return componentDefinitionsCollection.set(componentDefinitions, {
          validate: true,
          parse: true,
          silent: true
        });
      };
      _registerInstanceDefinitons = function(instanceDefinitions) {
        instanceDefinitionsCollection.targetPrefix = targetPrefix;
        return instanceDefinitionsCollection.set(instanceDefinitions, {
          validate: true,
          parse: true,
          silent: true
        });
      };
      _addInstanceToModel = function(instanceDefinition) {
        var args, componentClass, componentDefinition, height, instance;
        componentDefinition = componentDefinitionsCollection.get(instanceDefinition.get('componentId'));
        componentClass = componentDefinition.getClass();
        height = componentDefinition.get('height');
        if (instanceDefinition.get('height')) {
          height = instanceDefinition.get('height');
        }
        args = {
          urlParams: instanceDefinition.get('urlParams'),
          urlParamsModel: instanceDefinition.get('urlParamsModel')
        };
        _.extend(args, componentDefinition.get('args'));
        _.extend(args, instanceDefinition.get('args'));
        if (componentClass === IframeComponent) {
          args.src = componentDefinition.get('src');
        }
        instance = new componentClass(args);
        instance.$el.addClass(componentClassName);
        if (height) {
          instance.$el.style('height', height + "px");
        }
        instanceDefinition.set({
          'instance': instance
        }, {
          silent: true
        });
        return instanceDefinition;
      };
      _tryToReAddStraysToDom = function() {
        var j, len, render, results, stray, strays;
        strays = activeInstancesCollection.getStrays();
        results = [];
        for (j = 0, len = strays.length; j < len; j++) {
          stray = strays[j];
          render = false;
          _addInstanceToDom(stray, render);
          results.push(stray.get('instance').delegateEvents());
        }
        return results;
      };
      _addInstanceToDom = function(instanceDefinition, render) {
        var $target;
        if (render == null) {
          render = true;
        }
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        if (render) {
          instanceDefinition.renderInstance();
        }
        _addInstanceInOrder(instanceDefinition);
        instanceDefinition.incrementShowCount();
        return _isComponentAreaEmpty($target);
      };
      _addInstanceInOrder = function(instanceDefinition) {
        var $previousElement, $target, instance, order;
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        order = instanceDefinition.get('order');
        instance = instanceDefinition.get('instance');
        if (order) {
          if (order === 'top') {
            instance.$el.data('order', 0);
            $target.prepend(instance.$el);
          } else if (order === 'bottom') {
            instance.$el.data('order', 999);
            $target.append(instance.$el);
          } else {
            $previousElement = _previousElement($target.children().last(), order);
            instance.$el.data('order', order);
            instance.$el.attr('data-order', order);
            if (!$previousElement) {
              $target.prepend(instance.$el);
            } else {
              instance.$el.insertAfter($previousElement);
            }
          }
        } else {
          $target.append(instance.$el);
        }
        if (instanceDefinition.isAttached()) {
          if ((instance.onAddedToDom != null) && _.isFunction(instance.onAddedToDom)) {
            return instance.onAddedToDom();
          }
        }
      };
      _isComponentAreaEmpty = function($componentArea) {
        var isEmpty;
        isEmpty = $componentArea.length > 0;
        $componentArea.toggleClass('component-area--has-component', isEmpty);
        return isEmpty;
      };
      _onComponentAdded = function(instanceDefinition) {
        _addInstanceToModel(instanceDefinition);
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentChange = function(instanceDefinition) {
        instanceDefinition.disposeAndRemoveInstance();
        _addInstanceToModel(instanceDefinition);
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentRemoved = function(instanceDefinition) {
        var $target;
        instanceDefinition.disposeAndRemoveInstance();
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        return _isComponentAreaEmpty($target);
      };
      _onComponentOrderChange = function(instanceDefinition) {
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentTargetNameChange = function(instanceDefinition) {
        return _addInstanceToDom(instanceDefinition);
      };

      _.extend(componentManager, Backbone.Events);
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
