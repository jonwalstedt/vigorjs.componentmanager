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
    var ActiveComponentsCollection, ComponentDefinitionModel, ComponentDefinitionsCollection, FilterModel, IframeComponent, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, Vigor, router;
    Vigor = Backbone.Vigor = {};
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
        scrolling: false
      };

      IframeComponent.prototype.src = void 0;

      function IframeComponent(attrs) {
        _.extend(this.attributes, attrs.iframeAttributes);
        IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.initialize = function(attrs) {
        console.log('Im the IframeComponent');
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
        componentId: void 0,
        src: void 0,
        showcount: void 0,
        height: void 0,
        args: void 0,
        conditions: void 0,
        instance: void 0,
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
    ActiveComponentsCollection = (function(superClass) {
      extend(ActiveComponentsCollection, superClass);

      function ActiveComponentsCollection() {
        return ActiveComponentsCollection.__super__.constructor.apply(this, arguments);
      }

      ActiveComponentsCollection.prototype.model = ComponentDefinitionModel;

      ActiveComponentsCollection.prototype.getStrays = function() {
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

      return ActiveComponentsCollection;

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
        var elem, instance;
        instance = this.get('instance');
        elem = instance.el;
        return $.contains(document.body, elem);
      };

      InstanceDefinitionModel.prototype.dispose = function() {
        var instance;
        instance = this.get('instance');
        if (instance) {
          instance.dispose();
          return this.clear();
        }
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
        var instanceDefinition, instanceDefinitions, instanceDefinitionsArray, j, len, targetName;
        instanceDefinitionsArray = [];
        for (targetName in response) {
          instanceDefinitions = response[targetName];
          for (j = 0, len = instanceDefinitions.length; j < len; j++) {
            instanceDefinition = instanceDefinitions[j];
            instanceDefinition.targetName = TARGET_PREFIX + "--" + targetName;
            instanceDefinition.urlParamsModel = new Backbone.Model();
            if (instanceDefinition.urlPattern === 'global') {
              instanceDefinition.urlPattern = ['*notFound', '*action'];
            }
            instanceDefinitionsArray.push(instanceDefinition);
          }
        }
        return instanceDefinitionsArray;
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
    (function() {
      var $context, _addInstanceInOrder, _addInstanceToDom, _addInstanceToModel, _addListeners, _disposeAndRemoveInstanceFromModel, _filterInstanceDefinitions, _filterInstanceDefinitionsByShowConditions, _filterInstanceDefinitionsByShowCount, _getClass, _incrementShowCount, _isComponentAreaEmpty, _isUrl, _onComponentAdded, _onComponentChange, _onComponentOrderChange, _onComponentRemoved, _onComponentTargetNameChange, _parseComponentSettings, _previousElement, _registerComponents, _registerInstanceDefinitons, _removeListeners, _renderInstance, _tryToReAddStraysToDom, _updateActiveComponents, activeComponents, componentClassName, componentDefinitionsCollection, componentManager, conditions, filterModel, instanceDefinitionsCollection;
      componentClassName = 'vigor-component';
      componentDefinitionsCollection = void 0;
      instanceDefinitionsCollection = void 0;
      activeComponents = void 0;
      filterModel = void 0;
      $context = void 0;
      conditions = {};
      componentManager = {
        activeComponents: void 0,
        initialize: function(settings) {
          componentDefinitionsCollection = new ComponentDefinitionsCollection();
          instanceDefinitionsCollection = new InstanceDefinitionsCollection();
          activeComponents = new ActiveComponentsCollection();
          filterModel = new FilterModel();
          this.activeComponents = activeComponents;
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
        registerConditions: function(conditionsToBeRegistered) {
          return _.extend(conditions, conditionsToBeRegistered);
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
        updateInstance: function(instanceId, attributes) {
          var instanceDefinition;
          instanceDefinition = instanceDefinitionsCollection.get(instanceId);
          if (instanceDefinition != null) {
            instanceDefinition.set(attributes);
          }
          return this;
        },
        removeInstance: function(instancecId) {
          instanceDefinitionsCollection.remove(instancecId);
          return this;
        },
        clear: function() {
          var restrictions;
          componentDefinitionsCollection.reset();
          instanceDefinitionsCollection.reset();
          activeComponents.reset();
          filterModel.clear();
          (restrictions = {})();
          return this;
        },
        dispose: function() {
          var restrictions;
          this.clear();
          this._removeListeners();
          filterModel = void 0;
          activeComponents = void 0;
          restrictions = void 0;
          this.activeComponents = void 0;
          return componentDefinitionsCollection = void 0;
        },
        getComponentInstances: function(filterOptions) {
          var instance, instanceDefinition, instanceDefinitions, instances, j, len;
          instanceDefinitions = _filterInstanceDefinitions(filterOptions);
          instances = [];
          for (j = 0, len = instanceDefinitions.length; j < len; j++) {
            instanceDefinition = instanceDefinitions[j];
            instance = instanceDefinition.get('instance');
            if (!instance) {
              _addInstanceToModel(instanceDefinition);
              instance = instanceDefinition.get('instance');
            }
            instances.push(instance);
          }
          return instances;
        }
      };
      _addListeners = function() {
        filterModel.on('add change remove', _updateActiveComponents);
        componentDefinitionsCollection.on('add change remove', _updateActiveComponents);
        instanceDefinitionsCollection.on('add change remove', _updateActiveComponents);
        activeComponents.on('add', _onComponentAdded);
        activeComponents.on('change', _onComponentChange);
        activeComponents.on('remove', _onComponentRemoved);
        activeComponents.on('change:order', _onComponentOrderChange);
        return activeComponents.on('change:targetName', _onComponentTargetNameChange);
      };
      _removeListeners = function() {
        activeComponents.off();
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
        activeComponents.set(instanceDefinitions);
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
          componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
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
          componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
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
      _getClass = function(src) {
        var componentClass, j, len, obj, part, srcObjParts;
        if (_isUrl(src)) {
          componentClass = IframeComponent;
          return componentClass;
        } else {
          if (typeof require === "function") {
            console.log('require stuff');
            componentClass = require(src);
          } else {
            obj = window;
            srcObjParts = src.split('.');
            for (j = 0, len = srcObjParts.length; j < len; j++) {
              part = srcObjParts[j];
              obj = obj[part];
            }
            componentClass = obj;
          }
          if (typeof componentClass !== "function") {
            throw "No constructor function found for " + src;
          }
          return componentClass;
        }
      };
      _parseComponentSettings = function(componentSettings) {
        var componentDefinitions, hidden, instanceDefinitions;
        componentDefinitions = componentSettings.components || componentSettings.widgets || componentSettings.componentDefinitions;
        instanceDefinitions = componentSettings.layoutsArray || componentSettings.targets || componentSettings.instanceDefinitions;
        componentClassName = componentSettings.componentClassName || componentClassName;
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
        return instanceDefinitionsCollection.set(instanceDefinitions, {
          validate: true,
          parse: true,
          silent: true
        });
      };
      _addInstanceToModel = function(instanceDefinition) {
        var args, componentClass, componentDefinition, instance, src;
        componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
        src = componentDefinition.get('src');
        componentClass = _getClass(src);
        args = {
          urlParams: instanceDefinition.get('urlParams'),
          urlParamsModel: instanceDefinition.get('urlParamsModel')
        };
        _.extend(args, instanceDefinition.get('args'));
        if (componentClass === IframeComponent) {
          args.src = src;
        }
        instance = new componentClass(args);
        instance.$el.addClass(componentClassName);
        instanceDefinition.set({
          'instance': instance
        }, {
          silent: true
        });
        return instanceDefinition;
      };
      _tryToReAddStraysToDom = function() {
        var j, len, render, results, stray, strays;
        strays = activeComponents.getStrays();
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
        var $target, instance;
        if (render == null) {
          render = true;
        }
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        instance = instanceDefinition.get('instance');
        if (render) {
          _renderInstance(instanceDefinition);
        }
        _addInstanceInOrder(instanceDefinition);
        _incrementShowCount(instanceDefinition);
        return _isComponentAreaEmpty($target);
      };
      _renderInstance = function(instanceDefinition) {
        var instance;
        instance = instanceDefinition.get('instance');
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
      _incrementShowCount = function(instanceDefinition, silent) {
        var showCount;
        if (silent == null) {
          silent = true;
        }
        showCount = instanceDefinition.get('showCount');
        showCount++;
        return instanceDefinition.set({
          'showCount': showCount
        }, {
          silent: silent
        });
      };
      _disposeAndRemoveInstanceFromModel = function(instanceDefinition) {
        var instance;
        instance = instanceDefinition.get('instance');
        instance.dispose();
        instance = void 0;
        return instanceDefinition.set({
          'instance': void 0
        }, {
          silent: true
        });
      };
      _isUrl = function(string) {
        var urlRegEx;
        urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
        return urlRegEx.test(string);
      };
      _isComponentAreaEmpty = function($componentArea) {
        var isEmpty;
        isEmpty = $componentArea.length > 0;
        $componentArea.addClass('component-area--has-component', isEmpty);
        return isEmpty;
      };
      _onComponentAdded = function(instanceDefinition) {
        _addInstanceToModel(instanceDefinition);
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentChange = function(instanceDefinition) {
        _disposeAndRemoveInstanceFromModel(instanceDefinition);
        _addInstanceToModel(instanceDefinition);
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentRemoved = function(instanceDefinition) {
        var $target;
        _disposeAndRemoveInstanceFromModel(instanceDefinition);
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        return _isComponentAreaEmpty($target);
      };
      _onComponentOrderChange = function(instanceDefinition) {
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentTargetNameChange = function(instanceDefinition) {
        return _addInstanceToDom(instanceDefinition);
      };
      return Vigor.componentManager = componentManager;
    })();
    return Vigor;
  });

}).call(this);
