/**
 * vigorjs.componentmanager - Helps you decouple Backbone applications
 * @version v0.0.2
 * @link 
 * @license MIT
 */
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    slice = [].slice;

  (function(root, factory) {
    var $, Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore', 'jquery'], function(Backbone, _, $) {
        return factory(root, Backbone, _);
      });
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      $ = require('jquery');
      module.exports = factory(root, Backbone, _, $);
    } else {
      root.Vigor = factory(root, root.Backbone, root._, root.$);
    }
  })(this, function(root, Backbone, _, $) {
    var ActiveInstancesCollection, BaseCollection, ComponentDefinitionModel, ComponentDefinitionsCollection, FilterModel, IframeComponent, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, Vigor, router;
    Vigor = Backbone.Vigor = root.Vigor || {};
    Vigor.extend = Vigor.extend || Backbone.Model.extend;
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(urls, fragment) {
        var args, j, len, url;
        if (_.isArray(urls)) {
          args = [];
          for (j = 0, len = urls.length; j < len; j++) {
            url = urls[j];
            args = this._getArgumentsFromUrl(url, fragment);
          }
          return args;
        } else {
          return this._getArgumentsFromUrl(urls, fragment);
        }
      };

      Router.prototype._getArgumentsFromUrl = function(url, fragment) {
        var args, origUrl;
        origUrl = url;
        if (!_.isRegExp(url)) {
          url = this._routeToRegExp(url);
        }
        args = [];
        if (url.exec(fragment)) {
          args = _.compact(this._extractParameters(url, fragment));
        }
        args = this._getParamsObject(origUrl, args);
        return args;
      };

      Router.prototype._getParamsObject = function(url, args) {
        var namedParam, names, optionalParam, optionalParams, params, splatParam, splats, storeNames;
        optionalParam = /\((.*?)\)/g;
        namedParam = /(\(\?)?:\w+/g;
        splatParam = /\*\w+/g;
        params = {};
        optionalParams = url.match(new RegExp(optionalParam));
        names = url.match(new RegExp(namedParam));
        splats = url.match(new RegExp(splatParam));
        storeNames = function(matches, args) {
          var i, j, len, name, results;
          results = [];
          for (i = j = 0, len = matches.length; j < len; i = ++j) {
            name = matches[i];
            name = name.replace(':', '').replace('(', '').replace(')', '').replace('*', '').replace('/', '');
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
    router = new Router();
    FilterModel = (function(superClass) {
      extend(FilterModel, superClass);

      function FilterModel() {
        return FilterModel.__super__.constructor.apply(this, arguments);
      }

      FilterModel.prototype.defaults = {
        url: void 0,
        includeIfStringMatches: void 0,
        hasToMatchString: void 0,
        cantMatchString: void 0,
        conditions: void 0
      };

      FilterModel.prototype.parse = function(attrs) {
        var newValues, url;
        if ((attrs != null ? attrs.url : void 0) === "") {
          url = "";
        } else {
          url = (attrs != null ? attrs.url : void 0) || this.get('url') || void 0;
        }
        newValues = {
          url: url,
          includeIfStringMatches: (attrs != null ? attrs.includeIfStringMatches : void 0) || void 0,
          hasToMatchString: (attrs != null ? attrs.hasToMatchString : void 0) || void 0,
          cantMatchString: (attrs != null ? attrs.cantMatchString : void 0) || void 0,
          conditions: (attrs != null ? attrs.conditions : void 0) || this.get('conditions') || void 0
        };
        return newValues;
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
        _.extend(this.attributes, attrs != null ? attrs.iframeAttributes : void 0);
        IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.initialize = function(attrs) {
        if ((attrs != null ? attrs.src : void 0) != null) {
          this.src = attrs.src;
        }
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
    Vigor.IframeComponent = IframeComponent;
    BaseCollection = (function(superClass) {
      extend(BaseCollection, superClass);

      function BaseCollection() {
        this._triggerUpdates = bind(this._triggerUpdates, this);
        this._onRemove = bind(this._onRemove, this);
        this._onChange = bind(this._onChange, this);
        this._onAdd = bind(this._onAdd, this);
        return BaseCollection.__super__.constructor.apply(this, arguments);
      }

      BaseCollection.prototype._throttledAddedModels = void 0;

      BaseCollection.prototype._throttledChangedModels = void 0;

      BaseCollection.prototype._throttledRemovedModels = void 0;

      BaseCollection.prototype._throttledTriggerUpdates = void 0;

      BaseCollection.prototype._throttleDelay = 50;

      BaseCollection.prototype.initialize = function() {
        this._throttledAddedModels = {};
        this._throttledChangedModels = {};
        this._throttledRemovedModels = {};
        this._throttledTriggerUpdates = _.throttle(this._triggerUpdates, this._throttleDelay, {
          leading: false
        });
        this.addThrottledListeners();
        return BaseCollection.__super__.initialize.apply(this, arguments);
      };

      BaseCollection.prototype.addThrottledListeners = function() {
        return this.on('all', this._onAll);
      };

      BaseCollection.prototype.getByIds = function(ids) {
        var id, j, len, models;
        models = [];
        for (j = 0, len = ids.length; j < len; j++) {
          id = ids[j];
          models.push(this.get(id));
        }
        return models;
      };

      BaseCollection.prototype.isEmpty = function() {
        return this.models.length <= 0;
      };

      BaseCollection.prototype._onAll = function() {
        var args, event;
        event = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        switch (event) {
          case 'add':
            this._onAdd.apply(this, args);
            break;
          case 'change':
            this._onChange.apply(this, args);
            break;
          case 'remove':
            this._onRemove.apply(this, args);
        }
        return this._throttledTriggerUpdates();
      };

      BaseCollection.prototype._onAdd = function(model) {
        return this._throttledAddedModels[model.id] = model;
      };

      BaseCollection.prototype._onChange = function(model) {
        return this._throttledChangedModels[model.id] = model;
      };

      BaseCollection.prototype._onRemove = function(model) {
        return this._throttledRemovedModels[model.id] = model;
      };

      BaseCollection.prototype._throttledAdd = function() {
        var event, models;
        event = BaseCollection.prototype.THROTTLED_ADD;
        models = _.values(this._throttledAddedModels);
        this._throttledAddedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      BaseCollection.prototype._throttledChange = function() {
        var event, models;
        event = BaseCollection.prototype.THROTTLED_CHANGE;
        models = _.values(this._throttledChangedModels);
        this._throttledChangedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      BaseCollection.prototype._throttledRemove = function() {
        var event, models;
        event = BaseCollection.prototype.THROTTLED_REMOVE;
        models = _.values(this._throttledRemovedModels);
        this._throttledRemovedModels = {};
        if (models.length > 0) {
          this.trigger(event, models, event);
        }
        return models;
      };

      BaseCollection.prototype._throttledDiff = function(added, changed, removed) {
        var consolidated, event, models;
        event = BaseCollection.prototype.THROTTLED_DIFF;
        if (added.length || changed.length || removed.length) {
          added = _.difference(added, removed);
          consolidated = _.uniq(added.concat(changed));
          models = {
            added: added,
            changed: changed,
            removed: removed,
            consolidated: consolidated
          };
          return this.trigger(event, models, event);
        }
      };

      BaseCollection.prototype._triggerUpdates = function() {
        return this._throttledDiff(this._throttledAdd(), this._throttledChange(), this._throttledRemove());
      };

      BaseCollection.prototype.THROTTLED_DIFF = 'throttled_diff';

      BaseCollection.prototype.THROTTLED_ADD = 'throttled_add';

      BaseCollection.prototype.THROTTLED_CHANGE = 'throttled_change';

      BaseCollection.prototype.THROTTLED_REMOVE = 'throttled_remove';

      return BaseCollection;

    })(Backbone.Collection);
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.defaults = {
        id: void 0,
        src: void 0,
        height: void 0,
        args: void 0,
        conditions: void 0,
        instance: void 0,
        maxShowCount: void 0
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
          componentClass = Vigor.IframeComponent;
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

      ComponentDefinitionModel.prototype.areConditionsMet = function(globalConditions) {
        var componentConditions, condition, j, len, shouldBeIncluded;
        componentConditions = this.get('conditions');
        shouldBeIncluded = true;
        if (componentConditions) {
          if (!_.isArray(componentConditions)) {
            componentConditions = [componentConditions];
          }
          for (j = 0, len = componentConditions.length; j < len; j++) {
            condition = componentConditions[j];
            if (_.isFunction(condition) && !condition()) {
              shouldBeIncluded = false;
              break;
            } else if (_.isString(condition)) {
              if (!globalConditions) {
                throw 'No global conditions was passed, condition could not be tested';
              }
              if (globalConditions[condition] == null) {
                throw "Trying to verify condition " + condition + " but it has not been registered yet";
              }
              shouldBeIncluded = globalConditions[condition]();
              if (!shouldBeIncluded) {
                break;
              }
            }
          }
        }
        return shouldBeIncluded;
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

    })(BaseCollection);
    InstanceDefinitionModel = (function(superClass) {
      extend(InstanceDefinitionModel, superClass);

      function InstanceDefinitionModel() {
        return InstanceDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionModel.prototype.defaults = {
        id: void 0,
        componentId: void 0,
        filterString: void 0,
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

      InstanceDefinitionModel.prototype.isAttached = function() {
        var attached, el, instance;
        instance = this.get('instance');
        attached = false;
        if (!instance.el && instance.$el) {
          el = instance.$el.get(0);
        }
        if (instance) {
          attached = $.contains(document.body, instance.el);
        }
        return attached;
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

      InstanceDefinitionModel.prototype.dispose = function() {
        var instance;
        instance = this.get('instance');
        if (instance) {
          instance.dispose();
          return this.clear();
        }
      };

      InstanceDefinitionModel.prototype.disposeInstance = function() {
        var instance;
        instance = this.get('instance');
        if (instance != null) {
          instance.dispose();
        }
        instance = void 0;
        return this.set({
          'instance': void 0
        }, {
          silent: true
        });
      };

      InstanceDefinitionModel.prototype.exceedsMaximumShowCount = function(componentMaxShowCount) {
        var maxShowCount, shouldBeIncluded, showCount;
        showCount = this.get('showCount');
        maxShowCount = this.get('maxShowCount');
        shouldBeIncluded = true;
        if (!maxShowCount) {
          maxShowCount = componentMaxShowCount;
        }
        if (maxShowCount) {
          if (showCount < maxShowCount) {
            shouldBeIncluded = true;
          } else {
            shouldBeIncluded = false;
          }
        }
        return shouldBeIncluded;
      };

      InstanceDefinitionModel.prototype.passesFilter = function(filter) {
        var areConditionsMet, filterStringMatch, urlMatch;
        if (filter.url || filter.url === '') {
          urlMatch = this.doesUrlPatternMatch(filter.url);
          if (urlMatch != null) {
            if (urlMatch === true) {
              this.addUrlParams(filter.url);
            } else {
              return false;
            }
          }
        }
        if (this.get('conditions')) {
          areConditionsMet = this.areConditionsMet(filter.conditions);
          if (areConditionsMet != null) {
            if (!areConditionsMet) {
              return false;
            }
          }
        }
        if (filter.includeIfStringMatches) {
          filterStringMatch = this.includeIfStringMatches(filter.includeIfStringMatches);
          if (filterStringMatch != null) {
            return filterStringMatch;
          }
        }
        if (filter.hasToMatchString) {
          return this.hasToMatchString(filter.hasToMatchString);
        }
        if (filter.cantMatchString) {
          return this.cantMatchString(filter.cantMatchString);
        }
        return true;
      };

      InstanceDefinitionModel.prototype.hasToMatchString = function(filterString) {
        return !!this.includeIfStringMatches(filterString);
      };

      InstanceDefinitionModel.prototype.cantMatchString = function(filterString) {
        return !this.hasToMatchString(filterString);
      };

      InstanceDefinitionModel.prototype.includeIfStringMatches = function(filterString) {
        var filter;
        filter = this.get('filterString');
        if (filter) {
          return !!filter.match(new RegExp(filterString));
        }
      };

      InstanceDefinitionModel.prototype.doesUrlPatternMatch = function(url) {
        var j, len, match, pattern, routeRegEx, urlPattern;
        match = false;
        urlPattern = this.get('urlPattern');
        if (urlPattern) {
          if (!_.isArray(urlPattern)) {
            urlPattern = [urlPattern];
          }
          for (j = 0, len = urlPattern.length; j < len; j++) {
            pattern = urlPattern[j];
            routeRegEx = router._routeToRegExp(pattern);
            match = routeRegEx.test(url);
            if (match) {
              return match;
            }
          }
          return match;
        } else {
          return void 0;
        }
      };

      InstanceDefinitionModel.prototype.areConditionsMet = function(globalConditions) {
        var condition, instanceConditions, j, len, shouldBeIncluded;
        instanceConditions = this.get('conditions');
        shouldBeIncluded = true;
        if (instanceConditions) {
          if (!_.isArray(instanceConditions)) {
            instanceConditions = [instanceConditions];
          }
          for (j = 0, len = instanceConditions.length; j < len; j++) {
            condition = instanceConditions[j];
            if (_.isFunction(condition) && !condition()) {
              shouldBeIncluded = false;
              break;
            } else if (_.isString(condition)) {
              if (!globalConditions) {
                throw 'No global conditions was passed, condition could not be tested';
              }
              if (globalConditions[condition] == null) {
                throw "Trying to verify condition " + condition + " but it has not been registered yet";
              }
              shouldBeIncluded = globalConditions[condition]();
              if (!shouldBeIncluded) {
                break;
              }
            }
          }
        }
        return shouldBeIncluded;
      };

      InstanceDefinitionModel.prototype.addUrlParams = function(url) {
        var urlParams, urlParamsModel;
        urlParams = router.getArguments(this.get('urlPattern'), url);
        urlParams.url = url;
        urlParamsModel = this.get('urlParamsModel');
        urlParamsModel.set(urlParams);
        return this.set({
          'urlParams': urlParams
        }, {
          silent: !this.get('reInstantiateOnUrlParamChange')
        });
      };

      return InstanceDefinitionModel;

    })(Backbone.Model);
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

      InstanceDefinitionsCollection.prototype.getInstanceDefinitions = function(filter) {
        return this.filter(function(instanceDefinitionModel) {
          return instanceDefinitionModel.passesFilter(filter);
        });
      };

      InstanceDefinitionsCollection.prototype.getInstanceDefinitionsByUrl = function(url) {
        return this.filterInstanceDefinitionsByUrl(this.models, url);
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByUrl = function(instanceDefinitions, url) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinitionModel) {
            return instanceDefinitionModel.doesUrlPatternMatch(url);
          };
        })(this));
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByString = function(instanceDefinitions, filterString) {
        return _.filter(instanceDefinitions, function(instanceDefinitionModel) {
          return instanceDefinitionModel.doesFilterStringMatch(filterString);
        });
      };

      InstanceDefinitionsCollection.prototype.filterInstanceDefinitionsByConditions = function(instanceDefinitions, conditions) {
        return _.filter(instanceDefinitions, function(instanceDefinitionModel) {
          return instanceDefinitionModel.areConditionsMet(conditions);
        });
      };

      InstanceDefinitionsCollection.prototype.addUrlParams = function(instanceDefinitions, url) {
        var instanceDefinitionModel, j, len;
        for (j = 0, len = instanceDefinitions.length; j < len; j++) {
          instanceDefinitionModel = instanceDefinitions[j];
          instanceDefinitionModel.addUrlParams(url);
        }
        return instanceDefinitions;
      };

      return InstanceDefinitionsCollection;

    })(BaseCollection);
    ActiveInstancesCollection = (function(superClass) {
      extend(ActiveInstancesCollection, superClass);

      function ActiveInstancesCollection() {
        return ActiveInstancesCollection.__super__.constructor.apply(this, arguments);
      }

      ActiveInstancesCollection.prototype.model = InstanceDefinitionModel;

      ActiveInstancesCollection.prototype.getStrays = function() {
        return _.filter(this.models, (function(_this) {
          return function(model) {
            return !model.isAttached();
          };
        })(this));
      };

      return ActiveInstancesCollection;

    })(BaseCollection);
    (function() {
      var $context, ERROR, EVENTS, __testOnly, _addInstanceInOrder, _addInstanceToDom, _addInstanceToModel, _addListeners, _filterInstanceDefinitions, _filterInstanceDefinitionsByComponentConditions, _filterInstanceDefinitionsByShowCount, _isComponentAreaEmpty, _onComponentAdded, _onComponentChange, _onComponentOrderChange, _onComponentRemoved, _onComponentTargetNameChange, _parseComponentSettings, _previousElement, _registerComponents, _registerInstanceDefinitons, _removeListeners, _serialize, _tryToReAddStraysToDom, _updateActiveComponents, activeInstancesCollection, componentClassName, componentDefinitionsCollection, componentManager, filterModel, instanceDefinitionsCollection, targetPrefix;
      componentClassName = 'vigor-component';
      targetPrefix = 'component-area';
      componentDefinitionsCollection = void 0;
      instanceDefinitionsCollection = void 0;
      activeInstancesCollection = void 0;
      filterModel = void 0;
      $context = void 0;
      ERROR = {
        UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?',
        UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'
      };
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
          var conditions, silent;
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
          conditions = settings.componentSettings.conditions;
          if (conditions && !_.isEmpty(conditions)) {
            silent = true;
            this.registerConditions(settings.componentSettings.conditions, silent);
          }
          if (settings.componentSettings) {
            _parseComponentSettings(settings.componentSettings);
          }
          return this;
        },
        updateSettings: function(settings) {
          componentClassName = settings.componentClassName || componentClassName;
          targetPrefix = settings.targetPrefix || targetPrefix;
          return this;
        },
        refresh: function(filterOptions) {
          if (filterOptions) {
            filterModel.set(filterModel.parse(filterOptions));
          } else {
            _updateActiveComponents();
          }
          return this;
        },
        serialize: function() {
          return _serialize();
        },
        addComponents: function(componentDefinition) {
          componentDefinitionsCollection.set(componentDefinition, {
            parse: true,
            validate: true,
            remove: false
          });
          return this;
        },
        addInstance: function(instanceDefinition) {
          instanceDefinitionsCollection.set(instanceDefinition, {
            parse: true,
            validate: true,
            remove: false
          });
          return this;
        },
        updateComponents: function(componentDefinitions) {
          componentDefinitionsCollection.set(componentDefinitions, {
            parse: true,
            validate: true,
            remove: false
          });
          return this;
        },
        updateInstances: function(instanceDefinitions) {
          instanceDefinitionsCollection.set(instanceDefinitions, {
            parse: true,
            validate: true,
            remove: false
          });
          return this;
        },
        removeComponent: function(componentDefinitionId) {
          instanceDefinitionsCollection.remove(componentDefinitionId);
          return this;
        },
        removeInstance: function(instanceId) {
          instanceDefinitionsCollection.remove(instanceId);
          return this;
        },
        getComponentById: function(componentId) {
          var ref;
          return (ref = componentDefinitionsCollection.get(componentId)) != null ? ref.toJSON() : void 0;
        },
        getInstanceById: function(instanceId) {
          var ref;
          return (ref = instanceDefinitionsCollection.get(instanceId)) != null ? ref.toJSON() : void 0;
        },
        getComponents: function() {
          return componentDefinitionsCollection.toJSON();
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
        getConditions: function() {
          return filterModel.get('conditions');
        },
        registerConditions: function(conditionsToBeRegistered, silent) {
          var conditions;
          if (silent == null) {
            silent = false;
          }
          conditions = filterModel.get('conditions') || {};
          conditions = _.extend(conditions, conditionsToBeRegistered);
          filterModel.set({
            'conditions': conditions
          }, {
            silent: silent
          });
          return this;
        },
        clear: function() {
          componentDefinitionsCollection.reset();
          instanceDefinitionsCollection.reset();
          activeInstancesCollection.reset();
          filterModel.clear();
          return this;
        },
        dispose: function() {
          var conditions;
          this.clear();
          this._removeListeners();
          filterModel = void 0;
          activeInstancesCollection = void 0;
          conditions = void 0;
          return componentDefinitionsCollection = void 0;
        }
      };
      _addListeners = function() {
        filterModel.on('change', _updateActiveComponents);
        componentDefinitionsCollection.on('throttled_diff', _updateActiveComponents);
        instanceDefinitionsCollection.on('throttled_diff', _updateActiveComponents);
        activeInstancesCollection.on('add', _onComponentAdded);
        activeInstancesCollection.on('change:componentId change:filterString change:conditions change:args change:showCount change:urlPattern change:urlParams change:reInstantiateOnUrlParamChange', _onComponentChange);
        activeInstancesCollection.on('change:order', _onComponentOrderChange);
        activeInstancesCollection.on('change:targetName', _onComponentTargetNameChange);
        activeInstancesCollection.on('remove', _onComponentRemoved);
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
        var instanceDefinitions;
        instanceDefinitions = _filterInstanceDefinitions(filterModel.toJSON());
        activeInstancesCollection.set(instanceDefinitions);
        return _tryToReAddStraysToDom();
      };
      _filterInstanceDefinitions = function(filterOptions) {
        var instanceDefinitions;
        instanceDefinitions = instanceDefinitionsCollection.getInstanceDefinitions(filterOptions);
        instanceDefinitions = _filterInstanceDefinitionsByShowCount(instanceDefinitions);
        instanceDefinitions = _filterInstanceDefinitionsByComponentConditions(instanceDefinitions);
        return instanceDefinitions;
      };
      _filterInstanceDefinitionsByShowCount = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, function(instanceDefinition) {
          var componentDefinition, componentMaxShowCount;
          componentDefinition = componentDefinitionsCollection.get(instanceDefinition.get('componentId'));
          if (!componentDefinition) {
            throw ERROR.UNKNOWN_COMPONENT_DEFINITION;
          }
          componentMaxShowCount = componentDefinition.get('maxShowCount');
          return instanceDefinition.exceedsMaximumShowCount(componentMaxShowCount);
        });
      };
      _filterInstanceDefinitionsByComponentConditions = function(instanceDefinitions) {
        var globalConditions;
        globalConditions = filterModel.get('conditions');
        return _.filter(instanceDefinitions, function(instanceDefinition) {
          var componentDefinition;
          componentDefinition = componentDefinitionsCollection.get(instanceDefinition.get('componentId'));
          return componentDefinition.areConditionsMet(globalConditions);
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
        var args, componentArgs, componentClass, componentDefinition, height, instance, instanceArgs;
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
        componentArgs = componentDefinition.get('args');
        instanceArgs = instanceDefinition.get('args');
        if (((componentArgs != null ? componentArgs.iframeAttributes : void 0) != null) && ((instanceArgs != null ? instanceArgs.iframeAttributes : void 0) != null)) {
          instanceArgs.iframeAttributes = _.extend(componentArgs.iframeAttributes, instanceArgs.iframeAttributes);
        }
        _.extend(args, componentArgs);
        _.extend(args, instanceArgs);
        if (componentClass === Vigor.IframeComponent) {
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
        var instance, j, len, ref, render, results, stray;
        ref = activeInstancesCollection.getStrays();
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          stray = ref[j];
          render = false;
          if (_addInstanceToDom(stray, render)) {
            instance = stray.get('instance');
            if ((instance != null ? instance.delegateEvents : void 0) != null) {
              results.push(instance.delegateEvents());
            } else {
              results.push(void 0);
            }
          } else {
            results.push(stray.disposeInstance());
          }
        }
        return results;
      };
      _addInstanceToDom = function(instanceDefinition, render) {
        var $target, success;
        if (render == null) {
          render = true;
        }
        $target = $("." + (instanceDefinition.get('targetName')), $context);
        success = false;
        if (render) {
          instanceDefinition.renderInstance();
        }
        if ($target.length > 0) {
          _addInstanceInOrder(instanceDefinition);
          _isComponentAreaEmpty($target);
          success = true;
        }
        return success;
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
      _serialize = function() {
        var componentSettings, components, conditions, filter, hidden, instanceDefinition, instances, j, len;
        conditions = filterModel.get('conditions') || {};
        hidden = [];
        components = componentDefinitionsCollection.toJSON();
        instances = instanceDefinitionsCollection.toJSON();
        componentSettings = {};
        for (j = 0, len = instances.length; j < len; j++) {
          instanceDefinition = instances[j];
          instanceDefinition.instance = void 0;
        }
        componentSettings = {
          conditions: conditions,
          components: components,
          hidden: hidden,
          instanceDefinitions: instances
        };
        filter = function(key, value) {
          if (typeof value === 'function') {
            return value.toString();
          }
          return value;
        };
        return JSON.stringify(componentSettings, filter, 2);
      };
      _onComponentAdded = function(instanceDefinition) {
        _addInstanceToModel(instanceDefinition);
        _addInstanceToDom(instanceDefinition);
        return instanceDefinition.incrementShowCount();
      };
      _onComponentChange = function(instanceDefinition) {
        if (instanceDefinition.passesFilter(filterModel.toJSON())) {
          instanceDefinition.disposeInstance();
          _addInstanceToModel(instanceDefinition);
          return _addInstanceToDom(instanceDefinition);
        }
      };
      _onComponentRemoved = function(instanceDefinition) {
        var $target;
        instanceDefinition.disposeInstance();
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
