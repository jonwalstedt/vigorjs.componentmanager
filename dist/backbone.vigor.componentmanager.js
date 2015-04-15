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
    Vigor.extend = Backbone.Model.extend;
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(routes, fragment) {
        var args, i, len, route;
        if (_.isArray(routes)) {
          args = [];
          for (i = 0, len = routes.length; i < len; i++) {
            route = routes[i];
            args = this._getArgumentsFromRoute(route, fragment);
          }
          return args;
        } else {
          return this._getArgumentsFromRoute(routes, fragment);
        }
      };

      Router.prototype._getArgumentsFromRoute = function(route, fragment) {
        var args;
        if (!_.isRegExp(route)) {
          route = this._routeToRegExp(route);
        }
        args = [];
        if (route.exec(fragment)) {
          args = _.compact(this._extractParameters(route, fragment));
        }
        return args;
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

      function IframeComponent() {
        return IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.tagName = 'iframe';

      IframeComponent.prototype.className = 'vigor-component--iframe';

      IframeComponent.prototype.attributes = {
        seamless: 'seamless',
        scrolling: false
      };

      IframeComponent.prototype.src = void 0;

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
            var instance;
            if (instance = model.get('instance')) {
              return !_this.isAttached(instance);
            } else {
              return false;
            }
          };
        })(this));
        return strays;
      };

      ActiveComponentsCollection.prototype.isAttached = function(instance) {
        var elem;
        elem = instance.el;
        return $.contains(document.body, elem);
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
        urlPattern: void 0,
        args: void 0,
        order: void 0,
        targetName: void 0,
        instance: void 0,
        urlParams: void 0,
        showCount: 0
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
        var i, instanceDefinition, instanceDefinitions, instanceDefinitionsArray, len, targetName;
        instanceDefinitionsArray = [];
        for (targetName in response) {
          instanceDefinitions = response[targetName];
          for (i = 0, len = instanceDefinitions.length; i < len; i++) {
            instanceDefinition = instanceDefinitions[i];
            instanceDefinition.targetName = TARGET_PREFIX + "--" + targetName;
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
        return instanceDefinitions;
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinitionsByUrl = function(route) {
        return this.filterInstanceDefinitionsByUrl(this.models, route);
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByUrl = function(instanceDefinitions, route) {
        instanceDefinitions = _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinitionModel) {
            var i, len, match, pattern, routeRegEx, urlPattern;
            urlPattern = instanceDefinitionModel.get('urlPattern');
            if (urlPattern) {
              if (_.isArray(urlPattern)) {
                match = false;
                for (i = 0, len = urlPattern.length; i < len; i++) {
                  pattern = urlPattern[i];
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
        return instanceDefinitions;
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByString = function(instanceDefinitions, filterString) {
        instanceDefinitions = _.filter(instanceDefinitions, function(instanceDefinitionModel) {
          var filter;
          filter = instanceDefinitionModel.get('filter');
          if (!filter) {
            return false;
          } else {
            return filterString.match(new RegExp(filter));
          }
        });
        return instanceDefinitions;
      };

      InstanceDefinitionsCollection.prototype.addUrlParams = function(instanceDefinitions, route) {
        var i, instanceDefinition, len, urlParams;
        for (i = 0, len = instanceDefinitions.length; i < len; i++) {
          instanceDefinition = instanceDefinitions[i];
          urlParams = router.getArguments(instanceDefinition.get('urlPattern'), route);
          instanceDefinition.set({
            'urlParams': urlParams
          }, {
            silent: true
          });
        }
        return instanceDefinitions;
      };

      return InstanceDefinitionsCollection;

    })(Backbone.Collection);
    (function() {
      var $context, COMPONENT_CLASS, _addInstanceToDom, _addInstanceToModel, _filterInstanceDefinitions, _getClass, _incrementShowCount, _isUrl, _onComponentAdded, _onComponentOrderChange, _onComponentRemoved, _onComponentTargetNameChange, _parseComponentSettings, _previousElement, _registerComponents, _registerInstanceDefinitons, _tryToReAddStraysToDom, _updateActiveComponents, activeComponents, componentDefinitionsCollection, componentManager, filterModel, instanceDefinitionsCollection;
      COMPONENT_CLASS = 'vigor-component';
      componentDefinitionsCollection = new ComponentDefinitionsCollection();
      instanceDefinitionsCollection = new InstanceDefinitionsCollection();
      activeComponents = new ActiveComponentsCollection();
      filterModel = new FilterModel();
      $context = void 0;
      componentManager = {
        activeComponents: activeComponents,
        initialize: function(settings) {
          if (settings.componentSettings) {
            _parseComponentSettings(settings.componentSettings);
          }
          if (settings.$context) {
            $context = settings.$context;
          } else {
            $context = $('body');
          }
          filterModel.on('add change remove', _updateActiveComponents);
          componentDefinitionsCollection.on('add change remove', _updateActiveComponents);
          instanceDefinitionsCollection.on('add change remove', _updateActiveComponents);
          this.activeComponents.on('add', _onComponentAdded);
          this.activeComponents.on('remove', _onComponentRemoved);
          this.activeComponents.on('change:order', _onComponentOrderChange);
          this.activeComponents.on('change:targetName', _onComponentTargetNameChange);
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
          filterModel.clear();
          return this;
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
          var i, instance, instanceDefinition, instanceDefinitions, instances, len;
          instanceDefinitions = _filterInstanceDefinitions(filterOptions);
          instances = [];
          for (i = 0, len = instanceDefinitions.length; i < len; i++) {
            instanceDefinition = instanceDefinitions[i];
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
        instanceDefinitions = _filterInstanceDefinitions(filterOptions);
        activeComponents.set(instanceDefinitions);
        return _tryToReAddStraysToDom();
      };
      _filterInstanceDefinitions = function(filterOptions) {
        var componentDefinition, filteredInstanceDefinitions, i, instanceDefinition, instanceDefinitions, len, maxShowCount, showCount;
        instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions(filterOptions);
        filteredInstanceDefinitions = [];
        for (i = 0, len = instanceDefinitions.length; i < len; i++) {
          instanceDefinition = instanceDefinitions[i];
          componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
          showCount = instanceDefinition.get('showCount');
          maxShowCount = instanceDefinition.get('maxShowCount');
          if (!maxShowCount) {
            maxShowCount = componentDefinition.get('maxShowCount');
          }
          if (maxShowCount) {
            if (showCount < maxShowCount) {
              _incrementShowCount(instanceDefinition);
              filteredInstanceDefinitions.push(instanceDefinition);
            }
          } else {
            filteredInstanceDefinitions.push(instanceDefinition);
            _incrementShowCount(instanceDefinition);
          }
        }
        return filteredInstanceDefinitions;
      };
      _getClass = function(src) {
        var componentClass, i, len, obj, part, srcObjParts;
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
        }
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
      _addInstanceToDom = function(instanceDefinition, render) {
        var $previousElement, $target, instance, order;
        if (render == null) {
          render = true;
        }
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        order = instanceDefinition.get('order');
        instance = instanceDefinition.get('instance');
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
      _addInstanceToModel = function(instanceDefinition) {
        var args, componentClass, componentDefinition, instance, src;
        componentDefinition = componentDefinitionsCollection.getByComponentId(instanceDefinition.get('componentId'));
        src = componentDefinition.get('src');
        componentClass = _getClass(src);
        args = {
          urlParams: instanceDefinition.get('urlParams')
        };
        _.extend(args, instanceDefinition.get('args'));
        if (componentClass === IframeComponent) {
          args.src = src;
        }
        instance = new componentClass(args);
        instance.$el.addClass(COMPONENT_CLASS);
        instanceDefinition.set({
          'instance': instance
        }, {
          silent: true
        });
        return instanceDefinition;
      };
      _tryToReAddStraysToDom = function() {
        var i, len, render, results, stray, strays;
        strays = activeComponents.getStrays();
        results = [];
        for (i = 0, len = strays.length; i < len; i++) {
          stray = strays[i];
          render = false;
          _addInstanceToDom(stray, render);
          results.push(stray.get('instance').delegateEvents());
        }
        return results;
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
      _isUrl = function(string) {
        var urlRegEx;
        urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
        return urlRegEx.test(string);
      };
      _onComponentAdded = function(instanceDefinition) {
        _addInstanceToModel(instanceDefinition);
        return _addInstanceToDom(instanceDefinition);
      };
      _onComponentRemoved = function(instanceDefinition) {
        var instance;
        instance = instanceDefinition.get('instance');
        return instance.dispose();
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
