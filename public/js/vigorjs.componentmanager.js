/**
 * vigorjs.componentmanager - Helps you decouple Backbone applications
 * @version v0.9.4
 * @link http://jonwalstedt.github.io/vigorjs.componentmanager/
 * @license MIT
 */
(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  (function(root, factory) {
    var $, Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore', 'jquery'], function(Backbone, _, $) {
        return factory(root, Backbone, _, $);
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
    var ActiveInstanceDefinitionModel, ActiveInstancesCollection, BaseCollection, BaseInstanceCollection, BaseModel, ComponentDefinitionModel, ComponentDefinitionsCollection, ComponentManager, FilterModel, IframeComponent, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, UrlParamsCollection, UrlParamsModel, Vigor, __testOnly, router;
    Vigor = Backbone.Vigor = root.Vigor || {};
    Vigor.extend = Vigor.extend || Backbone.Model.extend;
    BaseCollection = (function(superClass) {
      extend(BaseCollection, superClass);

      function BaseCollection() {
        this._triggerUpdates = bind(this._triggerUpdates, this);
        this._onRemove = bind(this._onRemove, this);
        this._onChange = bind(this._onChange, this);
        this._onAdd = bind(this._onAdd, this);
        return BaseCollection.__super__.constructor.apply(this, arguments);
      }

      BaseCollection.prototype.THROTTLED_DIFF = 'throttled_diff';

      BaseCollection.prototype.THROTTLED_ADD = 'throttled_add';

      BaseCollection.prototype.THROTTLED_CHANGE = 'throttled_change';

      BaseCollection.prototype.THROTTLED_REMOVE = 'throttled_remove';

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

      return BaseCollection;

    })(Backbone.Collection);
    BaseModel = (function(superClass) {
      extend(BaseModel, superClass);

      function BaseModel() {
        return BaseModel.__super__.constructor.apply(this, arguments);
      }

      BaseModel.prototype.parse = function(data) {
        var field, j, len, ref;
        if ((data.vcmArgumentFields != null) && (data.vcmArgumentFieldValues == null)) {
          data.vcmArgumentFieldValues = {};
          ref = data.vcmArgumentFields;
          for (j = 0, len = ref.length; j < len; j++) {
            field = ref[j];
            data.vcmArgumentFieldValues[field.id] = field["default"];
          }
        }
        return data;
      };

      BaseModel.prototype.getArgs = function() {
        var args, vcmArgs;
        args = this.get('args') || {};
        vcmArgs = this.get('vcmArgumentFieldValues') || {};
        return _.extend({}, args, vcmArgs);
      };

      BaseModel.prototype.getCustomProperties = function(ignorePropertiesWithUndefinedValues) {
        var blackListedKeys, customProperties, key, val;
        if (ignorePropertiesWithUndefinedValues == null) {
          ignorePropertiesWithUndefinedValues = true;
        }
        blackListedKeys = _.keys(this.defaults);
        customProperties = _.omit(this.toJSON(), blackListedKeys);
        if (ignorePropertiesWithUndefinedValues) {
          for (key in customProperties) {
            val = customProperties[key];
            if (customProperties.hasOwnProperty(key) && customProperties[key] === void 0) {
              delete customProperties[key];
            }
          }
        }
        return customProperties;
      };

      BaseModel.prototype.dispose = function() {};

      return BaseModel;

    })(Backbone.Model);
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(urlPatterns, url) {
        var args, j, len, match, paramsObject, urlPattern;
        if (!_.isArray(urlPatterns)) {
          urlPatterns = [urlPatterns];
        }
        args = [];
        for (j = 0, len = urlPatterns.length; j < len; j++) {
          urlPattern = urlPatterns[j];
          match = this.doesUrlPatternMatch(urlPattern, url);
          if (match) {
            paramsObject = this._getArgumentsFromUrl(urlPattern, url);
            paramsObject._id = urlPattern;
            paramsObject.url = url;
          } else {
            paramsObject = {
              _id: urlPattern,
              url: url
            };
          }
          args.push(paramsObject);
        }
        return args;
      };

      Router.prototype.routeToRegExp = function(urlPattern) {
        return this._routeToRegExp(urlPattern);
      };

      Router.prototype.doesUrlPatternMatch = function(urlPattern, url) {
        var routeRegEx;
        if (urlPattern === 'global') {
          return true;
        }
        routeRegEx = this.routeToRegExp(urlPattern);
        return routeRegEx.test(url);
      };

      Router.prototype._getArgumentsFromUrl = function(urlPattern, url) {
        var extractedParams, origUrlPattern;
        origUrlPattern = urlPattern;
        if (!_.isRegExp(urlPattern)) {
          urlPattern = this._routeToRegExp(urlPattern);
        }
        if (urlPattern.exec(url)) {
          extractedParams = _.compact(this._extractParameters(urlPattern, url));
        }
        return this._getParamsObject(origUrlPattern, extractedParams);
      };

      Router.prototype._getParamsObject = function(urlPattern, extractedParams) {
        var namedParam, names, optionalParam, optionalParams, params, splatParam, splats, storeNames;
        if (!_.isString(urlPattern)) {
          return extractedParams;
        }
        optionalParam = /\((.*?)\)/g;
        namedParam = /(\(\?)?:\w+/g;
        splatParam = /\*\w+/g;
        params = {};
        optionalParams = urlPattern.match(new RegExp(optionalParam));
        names = urlPattern.match(new RegExp(namedParam));
        splats = urlPattern.match(new RegExp(splatParam));
        storeNames = function(matches, args) {
          var i, j, len, name, results;
          results = [];
          for (i = j = 0, len = matches.length; j < len; i = ++j) {
            name = matches[i];
            name = name.replace(/([^a-z0-9]+)/gi, '');
            results.push(params[name] = args[i]);
          }
          return results;
        };
        if (optionalParams) {
          storeNames(optionalParams, extractedParams);
        }
        if (names) {
          storeNames(names, extractedParams);
        }
        if (splats) {
          storeNames(splats, extractedParams);
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
        filterString: void 0,
        includeIfMatch: void 0,
        excludeIfMatch: void 0,
        hasToMatch: void 0,
        cantMatch: void 0,
        options: {
          add: true,
          remove: true,
          merge: true,
          invert: false,
          forceFilterStringMatching: false
        }
      };

      FilterModel.prototype.parse = function(attrs) {
        var props;
        this.clear({
          silent: true
        });
        props = _.extend({}, this.defaults, attrs);
        props.options = _.extend({}, this.defaults.options, props.options);
        return props;
      };

      FilterModel.prototype.serialize = function(excludeOptions) {
        var filter;
        if (excludeOptions == null) {
          excludeOptions = true;
        }
        if (excludeOptions) {
          filter = _.omit(this.toJSON(), 'options');
        } else {
          filter = this.toJSON();
        }
        return JSON.stringify(filter);
      };

      return FilterModel;

    })(BaseModel);
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

      IframeComponent.prototype.targetOrigin = 'http://localhost:7070';

      function IframeComponent(attrs) {
        this.onIframeLoaded = bind(this.onIframeLoaded, this);
        _.extend(this.attributes, attrs != null ? attrs.iframeAttributes : void 0);
        if (attrs != null ? attrs.targetOrigin : void 0) {
          this.targetOrigin = attrs.targetOrigin;
        }
        IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.initialize = function(attrs) {
        this.addListeners();
        if ((attrs != null ? attrs.src : void 0) != null) {
          this.src = attrs.src;
        }
        return IframeComponent.__super__.initialize.apply(this, arguments);
      };

      IframeComponent.prototype.addListeners = function() {
        return this.$el.on('load', this.onIframeLoaded);
      };

      IframeComponent.prototype.removeListeners = function() {
        return this.$el.off('load', this.onIframeLoaded);
      };

      IframeComponent.prototype.render = function() {
        this.$el.attr('src', this.src);
        return this;
      };

      IframeComponent.prototype.dispose = function() {
        this.removeListeners();
        return this.remove();
      };

      IframeComponent.prototype.postMessageToIframe = function(message) {
        var iframeWin;
        iframeWin = this.$el.get(0).contentWindow;
        return iframeWin.postMessage(message, this.targetOrigin);
      };

      IframeComponent.prototype.receiveMessage = function(message) {};

      IframeComponent.prototype.onIframeLoaded = function(event) {};

      return IframeComponent;

    })(Backbone.View);
    Vigor.IframeComponent = IframeComponent;
    ComponentDefinitionModel = (function(superClass) {
      extend(ComponentDefinitionModel, superClass);

      function ComponentDefinitionModel() {
        return ComponentDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionModel.prototype.ERROR = {
        VALIDATION: {
          ID_UNDEFINED: 'id cant be undefined',
          ID_NOT_A_STRING: 'id should be a string',
          ID_IS_EMPTY_STRING: 'id can not be an empty string',
          SRC_UNDEFINED: 'src cant be undefined',
          SRC_WRONG_TYPE: 'src should be a string or a constructor function',
          SRC_IS_EMPTY_STRING: 'src can not be an empty string'
        },
        NO_CONSTRUCTOR_FOUND: function(src) {
          return "No constructor function found for " + src;
        },
        MISSING_CONDITION: function(condition) {
          return "Trying to verify condition " + condition + " but it has not been registered yet";
        }
      };

      ComponentDefinitionModel.prototype.defaults = {
        id: void 0,
        src: void 0,
        componentClass: void 0,
        args: void 0,
        conditions: void 0,
        maxShowCount: void 0,
        vcmArgumentFields: void 0,
        vcmArgumentFieldValues: void 0
      };

      ComponentDefinitionModel.prototype.deferred = void 0;

      ComponentDefinitionModel.prototype.initialize = function() {
        this.deferred = $.Deferred();
        return ComponentDefinitionModel.__super__.initialize.apply(this, arguments);
      };

      ComponentDefinitionModel.prototype.validate = function(attrs, options) {
        var isValidType;
        if (!attrs.id) {
          throw this.ERROR.VALIDATION.ID_UNDEFINED;
        }
        if (typeof attrs.id !== 'string') {
          throw this.ERROR.VALIDATION.ID_NOT_A_STRING;
        }
        if (/^\s+$/g.test(attrs.id)) {
          throw this.ERROR.VALIDATION.ID_IS_EMPTY_STRING;
        }
        if (!attrs.src) {
          throw this.ERROR.VALIDATION.SRC_UNDEFINED;
        }
        isValidType = _.isString(attrs.src) || _.isFunction(attrs.src);
        if (!isValidType) {
          throw this.ERROR.VALIDATION.SRC_WRONG_TYPE;
        }
        if (_.isString(attrs.src) && /^\s+$/g.test(attrs.src)) {
          throw this.ERROR.VALIDATION.SRC_IS_EMPTY_STRING;
        }
      };

      ComponentDefinitionModel.prototype.getClass = function() {
        var j, len, obj, part, resolveClassPromise, src, srcObjParts;
        src = this.get('src');
        resolveClassPromise = (function(_this) {
          return function(componentClass) {
            if (_.isFunction(componentClass)) {
              _this.set('componentClass', componentClass, {
                silent: true
              });
              return _this.deferred.resolve({
                componentDefinition: _this,
                componentClass: componentClass
              });
            } else {
              throw _this.ERROR.NO_CONSTRUCTOR_FOUND(src);
            }
          };
        })(this);
        if (this.get('componentClass')) {
          resolveClassPromise(this.get('componentClass'));
        } else {
          if (_.isString(src) && this._isUrl(src)) {
            resolveClassPromise(Vigor.IframeComponent);
          } else if (_.isString(src)) {
            if (_.isString(src) && typeof define === "function" && define.amd) {
              Vigor.require([src], (function(_this) {
                return function(componentClass) {
                  return resolveClassPromise(componentClass);
                };
              })(this));
            } else if (_.isString(src) && typeof exports === "object") {
              resolveClassPromise(Vigor.require(src));
            } else {
              obj = window;
              srcObjParts = src.split('.');
              for (j = 0, len = srcObjParts.length; j < len; j++) {
                part = srcObjParts[j];
                obj = obj[part];
              }
              resolveClassPromise(obj);
            }
          } else if (_.isFunction(src)) {
            resolveClassPromise(src);
          } else {
            throw this.ERROR.VALIDATION.SRC_WRONG_TYPE;
          }
        }
        return this.deferred.promise();
      };

      ComponentDefinitionModel.prototype.getComponentClassPromise = function() {
        return this.deferred.promise();
      };

      ComponentDefinitionModel.prototype.passesFilter = function(filterModel, globalConditionsModel) {
        if (!this._areConditionsMet(filterModel, globalConditionsModel)) {
          return false;
        }
        return true;
      };

      ComponentDefinitionModel.prototype._areConditionsMet = function(filterModel, globalConditionsModel) {
        var componentConditions, condition, filter, globalConditions, j, len, shouldBeIncluded;
        filter = (filterModel != null ? filterModel.toJSON() : void 0) || {};
        globalConditions = (globalConditionsModel != null ? globalConditionsModel.toJSON() : void 0) || {};
        componentConditions = this.get('conditions');
        shouldBeIncluded = true;
        if (componentConditions) {
          if (!_.isArray(componentConditions)) {
            componentConditions = [componentConditions];
          }
          for (j = 0, len = componentConditions.length; j < len; j++) {
            condition = componentConditions[j];
            if (_.isFunction(condition) && !condition(filter, this.getArgs())) {
              shouldBeIncluded = false;
              break;
            } else if (_.isString(condition)) {
              if (globalConditions[condition] == null) {
                throw this.ERROR.MISSING_CONDITION(condition);
              }
              shouldBeIncluded = !!globalConditions[condition](filter, this.getArgs());
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

    })(BaseModel);
    ComponentDefinitionsCollection = (function(superClass) {
      extend(ComponentDefinitionsCollection, superClass);

      function ComponentDefinitionsCollection() {
        return ComponentDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      ComponentDefinitionsCollection.prototype.model = ComponentDefinitionModel;

      ComponentDefinitionsCollection.prototype.ERROR = {
        UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'
      };

      ComponentDefinitionsCollection.prototype.getComponentClassPromisesByInstanceDefinitions = function(instanceDefinitions) {
        var componentDefinition, instanceDefinition, j, len, promises;
        promises = [];
        for (j = 0, len = instanceDefinitions.length; j < len; j++) {
          instanceDefinition = instanceDefinitions[j];
          componentDefinition = this.getComponentDefinitionByInstanceDefinition(instanceDefinition);
          promises.push(componentDefinition.getClass());
        }
        return promises;
      };

      ComponentDefinitionsCollection.prototype.getComponentClassPromiseByInstanceDefinition = function(instanceDefinition) {
        var componentDefinition;
        componentDefinition = this.getComponentDefinitionByInstanceDefinition(instanceDefinition);
        return componentDefinition.getClass();
      };

      ComponentDefinitionsCollection.prototype.getComponentClassByInstanceDefinition = function(instanceDefinition) {
        var componentDefinition;
        componentDefinition = this.getComponentDefinitionByInstanceDefinition(instanceDefinition);
        return componentDefinition.get('componentClass');
      };

      ComponentDefinitionsCollection.prototype.getComponentDefinitionByInstanceDefinition = function(instanceDefinition) {
        var componentId;
        componentId = instanceDefinition.get('componentId');
        return this.getComponentDefinitionById(componentId);
      };

      ComponentDefinitionsCollection.prototype.getComponentDefinitionById = function(componentId) {
        var componentDefinition;
        componentDefinition = this.get(componentId);
        if (!componentDefinition) {
          throw this.ERROR.UNKNOWN_COMPONENT_DEFINITION;
        }
        return componentDefinition;
      };

      return ComponentDefinitionsCollection;

    })(BaseCollection);
    UrlParamsModel = (function(superClass) {
      extend(UrlParamsModel, superClass);

      function UrlParamsModel() {
        return UrlParamsModel.__super__.constructor.apply(this, arguments);
      }

      UrlParamsModel.prototype.idAttribute = "_id";

      return UrlParamsModel;

    })(Backbone.Model);
    UrlParamsCollection = (function(superClass) {
      extend(UrlParamsCollection, superClass);

      function UrlParamsCollection() {
        return UrlParamsCollection.__super__.constructor.apply(this, arguments);
      }

      UrlParamsCollection.prototype.model = UrlParamsModel;

      return UrlParamsCollection;

    })(Backbone.Collection);
    ActiveInstanceDefinitionModel = (function(superClass) {
      extend(ActiveInstanceDefinitionModel, superClass);

      function ActiveInstanceDefinitionModel() {
        return ActiveInstanceDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      ActiveInstanceDefinitionModel.prototype.ERROR = {
        MISSING_RENDER_METHOD: function(id) {
          return "The instance for " + id + " does not have a render method";
        }
      };

      ActiveInstanceDefinitionModel.prototype.defaults = {
        id: void 0,
        componentClass: void 0,
        target: void 0,
        targetPrefix: void 0,
        componentClassName: void 0,
        instanceArguments: void 0,
        order: void 0,
        reInstantiate: false,
        instance: void 0,
        urlParams: void 0,
        urlParamsCollection: void 0,
        serializedFilter: void 0
      };

      ActiveInstanceDefinitionModel.prototype.initialize = function() {
        ActiveInstanceDefinitionModel.__super__.initialize.apply(this, arguments);
        this.set('urlParamsCollection', new UrlParamsCollection(), {
          silent: true
        });
        this.listenTo(this, 'add', this._onAdd);
        this.listenTo(this, 'remove', this._onRemove);
        this.listenTo(this, 'change:instance', this._onInstanceChange);
        this.listenTo(this, 'change:urlParams', this._onUrlParamsChange);
        this.listenTo(this, 'change:order', this._onOrderChange);
        this.listenTo(this, 'change:target', this._onTargetChange);
        this.listenTo(this, 'change:componentClassName', this._onComponentClassNameChange);
        this.listenTo(this, 'change:serializedFilter', this._onSerializedFilterChange);
        this.listenTo(this, 'change:instanceArguments', this._onArgumentChange);
        return this._updateUrlParamsCollection();
      };

      ActiveInstanceDefinitionModel.prototype.tryToReAddStraysToDom = function() {
        var instance, isAttached;
        if (!this._isAttached()) {
          isAttached = this._addInstanceInOrder();
          if (isAttached) {
            instance = this.get('instance');
            if ((instance != null ? instance.delegateEvents : void 0) && _.isFunction(instance != null ? instance.delegateEvents : void 0)) {
              instance.delegateEvents();
            }
          } else {
            this._disposeInstance();
          }
          return this._updateTargetPopulatedState();
        }
      };

      ActiveInstanceDefinitionModel.prototype.dispose = function() {
        this._disposeInstance();
        this._updateTargetPopulatedState();
        this.stopListening();
        return this.off();
      };

      ActiveInstanceDefinitionModel.prototype._createInstance = function() {
        var componentClass, instance;
        componentClass = this.get('componentClass');
        instance = new componentClass(this._getInstanceArguments());
        this.set('instance', instance);
        return this._updateComponentClassNameOnInstance();
      };

      ActiveInstanceDefinitionModel.prototype._renderInstance = function() {
        var instance;
        instance = this.get('instance');
        if (!instance) {
          return;
        }
        if (!((instance.render != null) && _.isFunction(instance.render))) {
          throw this.ERROR.MISSING_RENDER_METHOD(this.get('id'));
        }
        if ((instance.preRender != null) && _.isFunction(instance.preRender)) {
          instance.preRender();
        }
        instance.render();
        if ((instance.postRender != null) && _.isFunction(instance.postRender)) {
          return instance.postRender();
        }
      };

      ActiveInstanceDefinitionModel.prototype._addInstanceInOrder = function() {
        var $previousElement, $target, instance, isAttached, order;
        instance = this.get('instance');
        $target = this.get('target');
        order = this.get('order');
        isAttached = false;
        if (order) {
          if (order === 'top') {
            instance.$el.data('order', 0);
            $target.prepend(instance.$el);
          } else if (order === 'bottom') {
            instance.$el.data('order', 999);
            $target.append(instance.$el);
          } else {
            $previousElement = this._getPrecedingElement($target.children().last(), order);
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
        isAttached = this._isAttached();
        if (isAttached) {
          if ((instance.onAddedToDom != null) && _.isFunction(instance.onAddedToDom)) {
            instance.onAddedToDom();
          }
        }
        return isAttached;
      };

      ActiveInstanceDefinitionModel.prototype._disposeInstance = function() {
        var instance;
        instance = this.get('instance');
        if ((instance != null ? instance.dispose : void 0) != null) {
          instance.dispose();
        }
        instance = void 0;
        return this.set('instance', void 0, {
          silent: true
        });
      };

      ActiveInstanceDefinitionModel.prototype._isTargetPopulated = function() {
        var $target;
        $target = this.get('target');
        return ($target != null ? $target.children().length : void 0) > 0;
      };

      ActiveInstanceDefinitionModel.prototype._updateTargetPopulatedState = function() {
        var $target, targetPrefix;
        $target = this.get('target');
        targetPrefix = this.get('targetPrefix');
        return $target != null ? $target.toggleClass(targetPrefix + "--has-components", this._isTargetPopulated()) : void 0;
      };

      ActiveInstanceDefinitionModel.prototype._isAttached = function() {
        var attached, el, instance;
        instance = this.get('instance');
        attached = false;
        if (!instance) {
          return attached;
        }
        if (!instance.el && instance.$el) {
          el = instance.$el.get(0);
        } else {
          el = instance.el;
        }
        if (instance) {
          attached = $.contains(document.body, el);
        }
        return attached;
      };

      ActiveInstanceDefinitionModel.prototype._getInstanceArguments = function() {
        var args;
        args = this.get('instanceArguments') || {};
        args.urlParams = this.get('urlParams');
        args.urlParamsCollection = this.get('urlParamsCollection');
        return args;
      };

      ActiveInstanceDefinitionModel.prototype._getPrecedingElement = function($el, order) {
        if (order == null) {
          order = 0;
        }
        if ($el.length > 0) {
          if ($el.data('order') <= order) {
            return $el;
          } else {
            return this._getPrecedingElement($el.prev(), order);
          }
        }
      };

      ActiveInstanceDefinitionModel.prototype._updateUrlParamsCollection = function() {
        var urlParams, urlParamsCollection;
        urlParams = this.get('urlParams');
        urlParamsCollection = this.get('urlParamsCollection');
        return urlParamsCollection.set(urlParams);
      };

      ActiveInstanceDefinitionModel.prototype._updateComponentClassNameOnInstance = function() {
        var componentClassName, instance, prevComponentClassName;
        instance = this.get('instance');
        componentClassName = this.get('componentClassName');
        prevComponentClassName = this.previousAttributes().componentClassName;
        if (componentClassName !== prevComponentClassName) {
          instance.$el.removeClass(prevComponentClassName);
        }
        return instance.$el.addClass(componentClassName);
      };

      ActiveInstanceDefinitionModel.prototype._onArgumentChange = function(model, value, options) {
        var currentArguments, prevArguments;
        prevArguments = _.omit(model.previousAttributes().instanceArguments, ['urlParams', 'urlParamsCollection']);
        currentArguments = _.omit(model.toJSON().instanceArguments, ['urlParams', 'urlParamsCollection']);
        if (!_.isEqual(prevArguments, currentArguments)) {
          this._disposeInstance();
          return this._createInstance();
        }
      };

      ActiveInstanceDefinitionModel.prototype._onComponentClassNameChange = function() {
        return this._updateComponentClassNameOnInstance();
      };

      ActiveInstanceDefinitionModel.prototype._onInstanceChange = function() {
        this._renderInstance();
        this._addInstanceInOrder();
        return this._updateTargetPopulatedState();
      };

      ActiveInstanceDefinitionModel.prototype._onUrlParamsChange = function() {
        return this._updateUrlParamsCollection();
      };

      ActiveInstanceDefinitionModel.prototype._onOrderChange = function() {
        return this._addInstanceInOrder();
      };

      ActiveInstanceDefinitionModel.prototype._onTargetChange = function() {
        return this._addInstanceInOrder();
      };

      ActiveInstanceDefinitionModel.prototype._onSerializedFilterChange = function() {
        if (this.get('reInstantiate')) {
          this._disposeInstance();
          return this._createInstance();
        }
      };

      ActiveInstanceDefinitionModel.prototype._onAdd = function() {
        return this._createInstance();
      };

      ActiveInstanceDefinitionModel.prototype._onRemove = function() {
        return this.dispose();
      };

      return ActiveInstanceDefinitionModel;

    })(BaseModel);
    InstanceDefinitionModel = (function(superClass) {
      extend(InstanceDefinitionModel, superClass);

      function InstanceDefinitionModel() {
        return InstanceDefinitionModel.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionModel.prototype.ERROR = {
        VALIDATION: {
          ID_UNDEFINED: 'id cant be undefined',
          ID_NOT_A_STRING: 'id should be a string',
          ID_IS_EMPTY_STRING: 'id can not be an empty string',
          COMPONENT_ID_UNDEFINED: 'componentId cant be undefined',
          COMPONENT_ID_NOT_A_STRING: 'componentId should be a string',
          COMPONENT_ID_IS_EMPTY_STRING: 'componentId can not be an empty string',
          TARGET_NAME_UNDEFINED: 'targetName cant be undefined',
          TARGET_WRONG_FORMAT: 'target should be a string or a jquery object'
        },
        MISSING_GLOBAL_CONDITIONS: 'No global conditions was passed, condition could not be tested',
        MISSING_CONDITION: function(condition) {
          return "Trying to verify condition " + condition + " but it has not been registered yet";
        }
      };

      InstanceDefinitionModel.prototype.defaults = {
        id: void 0,
        componentId: void 0,
        args: void 0,
        order: void 0,
        targetName: void 0,
        reInstantiate: false,
        filterString: void 0,
        includeIfFilterStringMatches: void 0,
        excludeIfFilterStringMatches: void 0,
        conditions: void 0,
        maxShowCount: void 0,
        urlPattern: void 0,
        showCount: 0,
        vcmArgumentFields: void 0,
        vcmArgumentFieldValues: void 0
      };

      InstanceDefinitionModel.prototype._$target = void 0;

      InstanceDefinitionModel.prototype.validate = function(attrs, options) {
        var ref;
        if (!attrs.id) {
          throw this.ERROR.VALIDATION.ID_UNDEFINED;
        }
        if (!_.isString(attrs.id)) {
          throw this.ERROR.VALIDATION.ID_NOT_A_STRING;
        }
        if (!/^.*[^ ].*$/.test(attrs.id)) {
          throw this.ERROR.VALIDATION.ID_IS_EMPTY_STRING;
        }
        if (!attrs.componentId) {
          throw this.ERROR.VALIDATION.COMPONENT_ID_UNDEFINED;
        }
        if (!_.isString(attrs.componentId)) {
          throw this.ERROR.VALIDATION.COMPONENT_ID_NOT_A_STRING;
        }
        if (!/^.*[^ ].*$/.test(attrs.componentId)) {
          throw this.ERROR.VALIDATION.COMPONENT_ID_IS_EMPTY_STRING;
        }
        if (!attrs.targetName) {
          throw this.ERROR.VALIDATION.TARGET_NAME_UNDEFINED;
        }
        if (!_.isString(attrs.targetName)) {
          if (((ref = attrs.targetName) != null ? ref.jquery : void 0) == null) {
            throw this.ERROR.VALIDATION.TARGET_WRONG_FORMAT;
          }
        }
      };

      InstanceDefinitionModel.prototype.incrementShowCount = function(silent) {
        var showCount;
        if (silent == null) {
          silent = true;
        }
        showCount = this.get('showCount');
        showCount++;
        return this.set('showCount', showCount, {
          silent: silent
        });
      };

      InstanceDefinitionModel.prototype.passesFilter = function(filterModel, globalConditionsModel) {
        var areConditionsMet, filter, filterStringMatch, globalConditions, ref, ref1, ref2, urlMatch;
        filter = (filterModel != null ? filterModel.toJSON() : void 0) || {};
        globalConditions = (globalConditionsModel != null ? globalConditionsModel.toJSON() : void 0) || {};
        if ((filter != null ? filter.url : void 0) || (filter != null ? filter.url : void 0) === '') {
          urlMatch = this._doesUrlPatternMatch(filter.url);
          if (urlMatch != null) {
            if (!urlMatch) {
              return false;
            }
          }
        }
        if (this.get('conditions')) {
          areConditionsMet = this._areConditionsMet(filter, globalConditions);
          if (areConditionsMet != null) {
            if (!areConditionsMet) {
              return false;
            }
          }
        }
        if (filter != null ? filter.filterString : void 0) {
          if (this.get('includeIfFilterStringMatches') != null) {
            filterStringMatch = this._includeIfFilterStringMatches(filter.filterString);
            if (filterStringMatch != null) {
              if (!filterStringMatch) {
                return false;
              }
            }
          }
          if (this.get('excludeIfFilterStringMatches') != null) {
            filterStringMatch = this._excludeIfFilterStringMatches(filter.filterString);
            if (filterStringMatch != null) {
              if (!filterStringMatch) {
                return false;
              }
            }
          }
        }
        if (filter != null ? (ref = filter.options) != null ? ref.forceFilterStringMatching : void 0 : void 0) {
          if ((this.get('filterString') != null) && (((filter != null ? filter.includeIfMatch : void 0) == null) && ((filter != null ? filter.excludeIfMatch : void 0) == null) && ((filter != null ? filter.hasToMatch : void 0) == null) && ((filter != null ? filter.cantMatch : void 0) == null))) {
            return false;
          }
        }
        if (filter != null ? filter.includeIfMatch : void 0) {
          filterStringMatch = this._includeIfMatch(filter.includeIfMatch);
          if (filter != null ? (ref1 = filter.options) != null ? ref1.forceFilterStringMatching : void 0 : void 0) {
            filterStringMatch = !!filterStringMatch;
          }
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.excludeIfMatch : void 0) {
          filterStringMatch = this._excludeIfMatch(filter.excludeIfMatch);
          if (filter != null ? (ref2 = filter.options) != null ? ref2.forceFilterStringMatching : void 0 : void 0) {
            filterStringMatch = !!filterStringMatch;
          }
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.hasToMatch : void 0) {
          filterStringMatch = this._hasToMatch(filter.hasToMatch);
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.cantMatch : void 0) {
          filterStringMatch = this._cantMatch(filter.cantMatch);
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        return true;
      };

      InstanceDefinitionModel.prototype.exceedsMaximumShowCount = function(componentMaxShowCount) {
        var exceedsShowCount, maxShowCount, showCount;
        showCount = this.get('showCount');
        maxShowCount = parseInt(this.get('maxShowCount', 10));
        exceedsShowCount = false;
        if (!maxShowCount) {
          maxShowCount = componentMaxShowCount;
        }
        if (maxShowCount) {
          if (showCount > maxShowCount) {
            exceedsShowCount = true;
          }
        }
        return exceedsShowCount;
      };

      InstanceDefinitionModel.prototype.isTargetAvailable = function($context, forceRefresh) {
        var ref;
        if ($context == null) {
          $context = $('body');
        }
        if (forceRefresh == null) {
          forceRefresh = true;
        }
        return ((ref = this.getTarget($context, forceRefresh)) != null ? ref.length : void 0) > 0;
      };

      InstanceDefinitionModel.prototype.getTarget = function($context, forceRefresh) {
        var ref, selector;
        if ($context == null) {
          $context = $('body');
        }
        if (forceRefresh == null) {
          forceRefresh = false;
        }
        selector = ((ref = this._$target) != null ? ref.selector : void 0) || '';
        if (!(selector.indexOf(this._getTargetName()) > -1) || forceRefresh) {
          this._refreshTarget($context);
        }
        return this._$target;
      };

      InstanceDefinitionModel.prototype.unsetTarget = function() {
        return this._$target = void 0;
      };

      InstanceDefinitionModel.prototype.updateTargetPrefix = function(targetPrefix) {
        var area, targetName;
        targetName = this.get('targetName');
        area = targetName.split('--')[1];
        return this.set('targetName', targetPrefix + "--" + area);
      };

      InstanceDefinitionModel.prototype._includeIfMatch = function(regexp) {
        var filterString;
        filterString = this.get('filterString');
        if (filterString) {
          return !!filterString.match(regexp);
        }
      };

      InstanceDefinitionModel.prototype._excludeIfMatch = function(regexp) {
        var filterString;
        filterString = this.get('filterString');
        if (filterString) {
          return !!!filterString.match(regexp);
        }
      };

      InstanceDefinitionModel.prototype._hasToMatch = function(regexp) {
        return !!this._includeIfMatch(regexp);
      };

      InstanceDefinitionModel.prototype._cantMatch = function(regexp) {
        return !!this._excludeIfMatch(regexp);
      };

      InstanceDefinitionModel.prototype._includeIfFilterStringMatches = function(filterString) {
        var regexp;
        regexp = this.get('includeIfFilterStringMatches');
        if (regexp) {
          return !!(filterString != null ? filterString.match(regexp) : void 0);
        }
      };

      InstanceDefinitionModel.prototype._excludeIfFilterStringMatches = function(filterString) {
        var regexp;
        regexp = this.get('excludeIfFilterStringMatches');
        if (regexp) {
          return !!!(filterString != null ? filterString.match(regexp) : void 0);
        }
      };

      InstanceDefinitionModel.prototype._doesUrlPatternMatch = function(url) {
        var j, len, match, pattern, urlPattern;
        match = false;
        urlPattern = this.get('urlPattern');
        if (urlPattern != null) {
          if (!_.isArray(urlPattern)) {
            urlPattern = [urlPattern];
          }
          for (j = 0, len = urlPattern.length; j < len; j++) {
            pattern = urlPattern[j];
            match = router.doesUrlPatternMatch(pattern, url);
            if (match) {
              return match;
            }
          }
          return match;
        } else {
          return void 0;
        }
      };

      InstanceDefinitionModel.prototype._areConditionsMet = function(filter, globalConditions) {
        var condition, instanceConditions, j, len, shouldBeIncluded;
        instanceConditions = this.get('conditions');
        shouldBeIncluded = true;
        if (instanceConditions) {
          if (!_.isArray(instanceConditions)) {
            instanceConditions = [instanceConditions];
          }
          for (j = 0, len = instanceConditions.length; j < len; j++) {
            condition = instanceConditions[j];
            if (_.isFunction(condition) && !condition(filter, this.getArgs())) {
              shouldBeIncluded = false;
              break;
            } else if (_.isString(condition)) {
              if (!globalConditions) {
                throw this.ERROR.MISSING_GLOBAL_CONDITIONS;
              }
              if (globalConditions[condition] == null) {
                throw this.ERROR.MISSING_CONDITION(condition);
              }
              shouldBeIncluded = globalConditions[condition](filter, this.getArgs());
              if (!shouldBeIncluded) {
                break;
              }
            }
          }
        }
        return shouldBeIncluded;
      };

      InstanceDefinitionModel.prototype._refreshTarget = function($context) {
        var $target, targetName;
        if ($context == null) {
          $context = $('body');
        }
        targetName = this._getTargetName();
        if (_.isString(targetName)) {
          if (targetName === 'body') {
            $target = $(targetName);
          } else {
            $target = $(targetName, $context);
          }
        } else {
          if ((targetName != null ? targetName.jquery : void 0) != null) {
            $target = targetName;
          } else {
            throw this.ERROR.VALIDATION.TARGET_WRONG_FORMAT;
          }
        }
        this._$target = $target;
        return this._$target;
      };

      InstanceDefinitionModel.prototype._getTargetName = function() {
        var targetName;
        targetName = this.get('targetName');
        if (_.isString(targetName)) {
          if (!(targetName === 'body' || targetName.charAt(0) === '.')) {
            targetName = "." + targetName;
          }
        }
        return targetName;
      };

      return InstanceDefinitionModel;

    })(BaseModel);
    BaseInstanceCollection = (function(superClass) {
      extend(BaseInstanceCollection, superClass);

      function BaseInstanceCollection() {
        return BaseInstanceCollection.__super__.constructor.apply(this, arguments);
      }

      BaseInstanceCollection.prototype.ERROR = {
        UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'
      };

      BaseInstanceCollection.prototype.model = InstanceDefinitionModel;

      BaseInstanceCollection.prototype.initialize = function() {
        this.on('reset', this._onReset);
        return BaseInstanceCollection.__super__.initialize.apply(this, arguments);
      };

      BaseInstanceCollection.prototype.getInstanceDefinitionById = function(instanceId) {
        var instanceDefinition;
        instanceDefinition = this.get(instanceId);
        if (!instanceDefinition) {
          throw this.ERROR.UNKNOWN_INSTANCE_DEFINITION;
        }
        return instanceDefinition;
      };

      BaseInstanceCollection.prototype._onReset = function(collection, options) {
        return _.invoke(options.previousModels, 'dispose');
      };

      return BaseInstanceCollection;

    })(BaseCollection);
    InstanceDefinitionsCollection = (function(superClass) {
      extend(InstanceDefinitionsCollection, superClass);

      function InstanceDefinitionsCollection() {
        return InstanceDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionsCollection.prototype.model = InstanceDefinitionModel;

      InstanceDefinitionsCollection.prototype.parse = function(data, options) {
        var i, incomingInstanceDefinitions, instanceDefinition, instanceDefinitions, instanceDefinitionsArray, j, k, len, len1, parsedResponse, targetName, targetPrefix;
        parsedResponse = void 0;
        instanceDefinitionsArray = [];
        targetPrefix = data.targetPrefix;
        incomingInstanceDefinitions = data.instanceDefinitions;
        if (_.isObject(incomingInstanceDefinitions) && !_.isArray(incomingInstanceDefinitions)) {
          for (targetName in incomingInstanceDefinitions) {
            instanceDefinitions = incomingInstanceDefinitions[targetName];
            if (_.isArray(instanceDefinitions)) {
              for (j = 0, len = instanceDefinitions.length; j < len; j++) {
                instanceDefinition = instanceDefinitions[j];
                instanceDefinition.targetName = this._formatTargetName(targetName, targetPrefix);
                instanceDefinitionsArray.push(instanceDefinition);
              }
              parsedResponse = instanceDefinitionsArray;
            } else {
              if (incomingInstanceDefinitions.targetName) {
                incomingInstanceDefinitions.targetName = this._formatTargetName(incomingInstanceDefinitions.targetName, targetPrefix);
              }
              parsedResponse = incomingInstanceDefinitions;
              break;
            }
          }
        } else if (_.isArray(incomingInstanceDefinitions)) {
          for (i = k = 0, len1 = incomingInstanceDefinitions.length; k < len1; i = ++k) {
            instanceDefinition = incomingInstanceDefinitions[i];
            if (instanceDefinition.targetName) {
              instanceDefinition.targetName = this._formatTargetName(instanceDefinition.targetName, targetPrefix);
            }
            incomingInstanceDefinitions[i] = instanceDefinition;
          }
          parsedResponse = incomingInstanceDefinitions;
        }
        return parsedResponse;
      };

      InstanceDefinitionsCollection.prototype._formatTargetName = function(targetName, targetPrefix) {
        if (_.isString(targetName)) {
          if (targetName !== 'body') {
            if (targetName.charAt(0) === '.') {
              targetName = targetName.substring(1);
            }
            if (targetName.indexOf(targetPrefix) < 0) {
              targetName = targetPrefix + "--" + targetName;
            }
            targetName = "." + targetName;
          }
        }
        return targetName;
      };

      return InstanceDefinitionsCollection;

    })(BaseInstanceCollection);
    ActiveInstancesCollection = (function(superClass) {
      extend(ActiveInstancesCollection, superClass);

      function ActiveInstancesCollection() {
        return ActiveInstancesCollection.__super__.constructor.apply(this, arguments);
      }

      ActiveInstancesCollection.prototype.model = ActiveInstanceDefinitionModel;

      return ActiveInstancesCollection;

    })(BaseInstanceCollection);
    ComponentManager = (function() {
      var COMPONENT_CLASS_NAME, COMPONENT_MANAGER_ID, TARGET_PREFIX, WHITELISTED_ORIGINS;

      function ComponentManager() {
        this._onMessageReceived = bind(this._onMessageReceived, this);
        this._onActiveInstanceAdd = bind(this._onActiveInstanceAdd, this);
        this._updateActiveComponents = bind(this._updateActiveComponents, this);
      }

      COMPONENT_MANAGER_ID = 'vigorjs.componentmanager';

      COMPONENT_CLASS_NAME = 'vigor-component';

      TARGET_PREFIX = 'component-area';

      WHITELISTED_ORIGINS = 'http://localhost:3000';

      ComponentManager.prototype.ERROR = {
        CONDITION: {
          WRONG_FORMAT: 'condition has to be an object with key value pairs'
        },
        MESSAGE: {
          MISSING_ID: 'The id of targeted instance must be passed as first argument',
          MISSING_MESSAGE: 'No message was passed',
          MISSING_RECEIVE_MESSAGE_METHOD: 'The instance does not seem to have a receiveMessage method'
        },
        CONTEXT: {
          WRONG_FORMAT: 'context should be a string or a jquery object'
        }
      };

      ComponentManager.prototype.EVENTS = {
        INITIALIZED: 'initialized',
        FILTER_CHANGE: 'filter-change',
        CONDITIONS_CHANGED: 'conditions-changed',
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

      ComponentManager.prototype._componentDefinitionsCollection = void 0;

      ComponentManager.prototype._instanceDefinitionsCollection = void 0;

      ComponentManager.prototype._activeInstancesCollection = void 0;

      ComponentManager.prototype._globalConditionsModel = void 0;

      ComponentManager.prototype._filterModel = void 0;

      ComponentManager.prototype._$context = void 0;

      ComponentManager.prototype._componentClassName = void 0;

      ComponentManager.prototype._targetPrefix = void 0;

      ComponentManager.prototype._listenForMessages = false;

      ComponentManager.prototype._whitelistedOrigins = WHITELISTED_ORIGINS;

      ComponentManager.prototype.initialize = function(settings) {
        this._componentDefinitionsCollection = new ComponentDefinitionsCollection();
        this._instanceDefinitionsCollection = new InstanceDefinitionsCollection();
        this._activeInstancesCollection = new ActiveInstancesCollection();
        this._globalConditionsModel = new Backbone.Model();
        this._filterModel = new FilterModel();
        if (settings && _.isString(settings)) {
          settings = this.parse(settings);
        }
        if ((settings != null ? settings.listenForMessages : void 0) != null) {
          this._listenForMessages = settings != null ? settings.listenForMessages : void 0;
        }
        this.addListeners();
        this._parse(settings);
        this.trigger(this.EVENTS.INITIALIZED, this);
        return this;
      };

      ComponentManager.prototype.updateSettings = function(settings) {
        if ((settings != null ? settings.listenForMessages : void 0) != null) {
          this._listenForMessages = settings != null ? settings.listenForMessages : void 0;
        }
        this._parse(settings);
        return this;
      };

      ComponentManager.prototype.refresh = function(filter) {
        var promise;
        this._filterModel.set(this._filterModel.parse(filter));
        promise = this._updateActiveComponents();
        promise.then((function(_this) {
          return function(returnData) {
            return _this.trigger(_this.EVENTS.FILTER_CHANGE, _this.getActiveFilter(), returnData);
          };
        })(this));
        return promise;
      };

      ComponentManager.prototype.serialize = function() {
        var $context, classes, componentDefinition, componentDefinitions, componentSettings, conditions, contextSelector, filter, instanceDefinitions, j, len, ref, settings, tagName;
        componentSettings = {};
        conditions = this._globalConditionsModel.toJSON();
        componentDefinitions = this._componentDefinitionsCollection.toJSON();
        instanceDefinitions = this._instanceDefinitionsCollection.toJSON();
        for (j = 0, len = componentDefinitions.length; j < len; j++) {
          componentDefinition = componentDefinitions[j];
          componentDefinition.componentClass = void 0;
        }
        $context = this.getContext();
        if ($context.length > 0) {
          tagName = $context.prop('tagName').toLowerCase();
          classes = (ref = $context.attr('class')) != null ? ref.replace(' ', '.') : void 0;
          contextSelector = $context.selector || (tagName + "." + classes);
        } else {
          contextSelector = 'body';
        }
        settings = {
          context: contextSelector,
          componentClassName: this.getComponentClassName(),
          targetPrefix: this.getTargetPrefix(),
          componentSettings: {
            conditions: conditions,
            components: componentDefinitions,
            instances: instanceDefinitions
          }
        };
        filter = function(key, value) {
          if (typeof value === 'function') {
            return value.toString();
          }
          return value;
        };
        return JSON.stringify(settings, filter);
      };

      ComponentManager.prototype.parse = function(jsonString, updateSettings) {
        var filter, settings;
        if (updateSettings == null) {
          updateSettings = false;
        }
        filter = function(key, value) {
          var args, body, endArgs, endBody, isFunction, isString, startArgs, startBody;
          isString = value && typeof value === 'string';
          isFunction = isString && value.substr(0, 8) === 'function';
          if (isString && isFunction) {
            startBody = value.indexOf('{') + 1;
            endBody = value.lastIndexOf('}');
            startArgs = value.indexOf('(') + 1;
            endArgs = value.indexOf(')');
            args = value.substring(startArgs, endArgs);
            body = value.substring(startBody, endBody);
            return new Function(args, body);
          }
          return value;
        };
        settings = JSON.parse(jsonString, filter);
        if (updateSettings) {
          this.updateSettings(settings);
        }
        return settings;
      };

      ComponentManager.prototype.clear = function() {
        var ref, ref1, ref2, ref3, ref4;
        if ((ref = this._componentDefinitionsCollection) != null) {
          ref.reset();
        }
        if ((ref1 = this._instanceDefinitionsCollection) != null) {
          ref1.reset();
        }
        if ((ref2 = this._activeInstancesCollection) != null) {
          ref2.reset();
        }
        if ((ref3 = this._filterModel) != null) {
          ref3.clear({
            silent: true
          });
        }
        if ((ref4 = this._globalConditionsModel) != null) {
          ref4.clear({
            silent: true
          });
        }
        this._$context = void 0;
        this._listenForMessages = false;
        this._componentClassName = COMPONENT_CLASS_NAME;
        this._targetPrefix = TARGET_PREFIX;
        this._whitelistedOrigins = [WHITELISTED_ORIGINS];
        return this;
      };

      ComponentManager.prototype.dispose = function() {
        this.clear();
        this.removeListeners();
        this._componentDefinitionsCollection = void 0;
        this._instanceDefinitionsCollection = void 0;
        this._globalConditionsModel = void 0;
        this._activeInstancesCollection = void 0;
        return this._filterModel = void 0;
      };

      ComponentManager.prototype.addListeners = function() {
        var eventMethod, eventer, messageEvent;
        this._componentDefinitionsCollection.on('throttled_diff', this._updateActiveComponents);
        this._instanceDefinitionsCollection.on('throttled_diff', this._updateActiveComponents);
        this._globalConditionsModel.on('change', this._updateActiveComponents);
        this._activeInstancesCollection.on('add', this._onActiveInstanceAdd);
        this._globalConditionsModel.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger(_this.EVENTS.CONDITIONS_CHANGED, model.toJSON());
          };
        })(this));
        this._componentDefinitionsCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.COMPONENT_ADD, model.toJSON(), collection.toJSON());
          };
        })(this));
        this._componentDefinitionsCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger(_this.EVENTS.COMPONENT_CHANGE, model.toJSON(), _this._componentDefinitionsCollection.toJSON());
          };
        })(this));
        this._componentDefinitionsCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.COMPONENT_REMOVE, model.toJSON(), collection.toJSON());
          };
        })(this));
        this._instanceDefinitionsCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.INSTANCE_ADD, model.toJSON(), collection.toJSON());
          };
        })(this));
        this._instanceDefinitionsCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger(_this.EVENTS.INSTANCE_CHANGE, model.toJSON(), _this._instanceDefinitionsCollection.toJSON());
          };
        })(this));
        this._instanceDefinitionsCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.INSTANCE_REMOVE, model.toJSON(), collection.toJSON());
          };
        })(this));
        this._activeInstancesCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.ADD, model.get('instance'), _this.getActiveInstances());
          };
        })(this));
        this._activeInstancesCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger(_this.EVENTS.CHANGE, model.get('instance'), _this.getActiveInstances());
          };
        })(this));
        this._activeInstancesCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger(_this.EVENTS.REMOVE, model.get('instance'), _this.getActiveInstances());
          };
        })(this));
        if (this._listenForMessages) {
          eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
          eventer = window[eventMethod];
          messageEvent = eventMethod === 'attachEvent' ? 'onmessage' : 'message';
          eventer(messageEvent, this._onMessageReceived, false);
        }
        return this;
      };

      ComponentManager.prototype.addConditions = function(conditions, silent) {
        var existingConditions;
        if (silent == null) {
          silent = false;
        }
        if (_.isObject(conditions)) {
          existingConditions = this._globalConditionsModel.get('conditions') || {};
          conditions = _.extend(existingConditions, conditions);
          this._globalConditionsModel.set(conditions, {
            silent: silent
          });
        } else {
          throw this.ERROR.CONDITION.WRONG_FORMAT;
        }
        return this;
      };

      ComponentManager.prototype.addComponentDefinitions = function(componentDefinitions) {
        this._componentDefinitionsCollection.set(componentDefinitions, {
          parse: true,
          validate: true,
          remove: false
        });
        return this;
      };

      ComponentManager.prototype.addInstanceDefinitions = function(instanceDefinitions) {
        var data;
        data = {
          instanceDefinitions: instanceDefinitions,
          targetPrefix: this.getTargetPrefix()
        };
        this._instanceDefinitionsCollection.set(data, {
          parse: true,
          validate: true,
          remove: false
        });
        return this;
      };

      ComponentManager.prototype.updateComponentDefinitions = function(componentDefinitions) {
        this.addComponentDefinitions(componentDefinitions);
        return this;
      };

      ComponentManager.prototype.updateInstanceDefinitions = function(instanceDefinitions) {
        this.addInstanceDefinitions(instanceDefinitions);
        return this;
      };

      ComponentManager.prototype.removeComponentDefinition = function(componentDefinitionId) {
        var instanceDefinitions;
        instanceDefinitions = this._instanceDefinitionsCollection.where({
          componentId: componentDefinitionId
        });
        this._instanceDefinitionsCollection.remove(instanceDefinitions);
        this._componentDefinitionsCollection.remove(componentDefinitionId);
        return this;
      };

      ComponentManager.prototype.removeInstanceDefinition = function(instanceDefinitionId) {
        this._instanceDefinitionsCollection.remove(instanceDefinitionId);
        return this;
      };

      ComponentManager.prototype.removeListeners = function() {
        var eventMethod, eventer, messageEvent, ref, ref1, ref2, ref3, ref4;
        if ((ref = this._activeInstancesCollection) != null) {
          ref.off();
        }
        if ((ref1 = this._filterModel) != null) {
          ref1.off();
        }
        if ((ref2 = this._instanceDefinitionsCollection) != null) {
          ref2.off();
        }
        if ((ref3 = this._componentDefinitionsCollection) != null) {
          ref3.off();
        }
        if ((ref4 = this._globalConditionsModel) != null) {
          ref4.off();
        }
        if (this._listenForMessages) {
          eventMethod = window.removeEventListener ? 'removeEventListener' : 'detachEvent';
          eventer = window[eventMethod];
          messageEvent = eventMethod === 'detachEvent' ? 'onmessage' : 'message';
          eventer(messageEvent, this._onMessageReceived);
        }
        return this;
      };

      ComponentManager.prototype.setContext = function(context, updateActiveComponents) {
        var ref, ref1;
        if (context == null) {
          context = 'body';
        }
        if (updateActiveComponents == null) {
          updateActiveComponents = true;
        }
        if (_.isString(context)) {
          this._$context = $(context);
        } else if (context.jquery != null) {
          this._$context = context;
        } else {
          throw this.ERROR.CONTEXT.WRONG_FORMAT;
        }
        if (updateActiveComponents) {
          _.invoke((ref = this._instanceDefinitionsCollection) != null ? ref.models : void 0, 'unsetTarget');
          if ((ref1 = this._activeInstancesCollection) != null) {
            ref1.reset();
          }
          this._updateActiveComponents();
        }
        return this;
      };

      ComponentManager.prototype.setComponentClassName = function(_componentClassName) {
        var ref;
        this._componentClassName = _componentClassName != null ? _componentClassName : COMPONENT_CLASS_NAME;
        _.invoke((ref = this._activeInstancesCollection) != null ? ref.models : void 0, 'set', {
          componentClassName: this._componentClassName
        });
        return this;
      };

      ComponentManager.prototype.setTargetPrefix = function(_targetPrefix) {
        var ref;
        this._targetPrefix = _targetPrefix != null ? _targetPrefix : TARGET_PREFIX;
        _.invoke((ref = this._instanceDefinitionsCollection) != null ? ref.models : void 0, 'updateTargetPrefix', this._targetPrefix);
        return this;
      };

      ComponentManager.prototype.setWhitelistedOrigins = function(_whitelistedOrigins) {
        this._whitelistedOrigins = _whitelistedOrigins != null ? _whitelistedOrigins : [WHITELISTED_ORIGINS];
        if (!_.isArray(this._whitelistedOrigins)) {
          this._whitelistedOrigins = [this._whitelistedOrigins];
        }
        return this;
      };

      ComponentManager.prototype.getContext = function() {
        return this._$context;
      };

      ComponentManager.prototype.getComponentClassName = function() {
        return this._componentClassName || COMPONENT_CLASS_NAME;
      };

      ComponentManager.prototype.getTargetPrefix = function() {
        return this._targetPrefix || TARGET_PREFIX;
      };

      ComponentManager.prototype.getListenForMessages = function() {
        return this._listenForMessages;
      };

      ComponentManager.prototype.getWhitelistedOrigins = function() {
        return this._whitelistedOrigins;
      };

      ComponentManager.prototype.getActiveFilter = function() {
        return this._filterModel.toJSON();
      };

      ComponentManager.prototype.getConditions = function() {
        return this._globalConditionsModel.toJSON();
      };

      ComponentManager.prototype.getComponentDefinitionById = function(componentDefinitionId) {
        return this._componentDefinitionsCollection.getComponentDefinitionById(componentDefinitionId).toJSON();
      };

      ComponentManager.prototype.getInstanceDefinitionById = function(instanceDefinitionId) {
        return this._instanceDefinitionsCollection.getInstanceDefinitionById(instanceDefinitionId).toJSON();
      };

      ComponentManager.prototype.getComponentDefinitions = function() {
        return this._componentDefinitionsCollection.toJSON();
      };

      ComponentManager.prototype.getInstanceDefinitions = function() {
        return this._instanceDefinitionsCollection.toJSON();
      };

      ComponentManager.prototype.getComponentDefinitionByInstanceDefinitionId = function(instanceDefinitionId) {
        var instanceDefinition;
        instanceDefinition = this._instanceDefinitionsCollection.getInstanceDefinitionById(instanceDefinitionId);
        return this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition).toJSON();
      };

      ComponentManager.prototype.getActiveInstances = function() {
        return this._mapInstances(this._activeInstancesCollection.models);
      };

      ComponentManager.prototype.getActiveInstancesByComponentId = function(componentDefinitionId) {
        return _.compact(_.map(this._activeInstancesCollection.models, (function(_this) {
          return function(model) {
            if (model.get('componentId') === componentDefinitionId) {
              return _this._mapInstances(model)[0];
            }
          };
        })(this)));
      };

      ComponentManager.prototype.getActiveInstanceById = function(instanceDefinitionId) {
        var ref;
        return (ref = this._activeInstancesCollection.getInstanceDefinitionById(instanceDefinitionId)) != null ? ref.get('instance') : void 0;
      };

      ComponentManager.prototype.postMessageToInstance = function(instanceDefinitionId, message) {
        var instance;
        if (!instanceDefinitionId) {
          throw this.ERROR.MESSAGE.MISSING_ID;
        }
        if (!message) {
          throw this.ERROR.MESSAGE.MISSING_MESSAGE;
        }
        instance = this.getActiveInstanceById(instanceDefinitionId);
        if (_.isFunction(instance != null ? instance.receiveMessage : void 0)) {
          return instance.receiveMessage(message);
        } else {
          throw this.ERROR.MESSAGE.MISSING_RECEIVE_MESSAGE_METHOD;
        }
      };

      ComponentManager.prototype._parse = function(settings) {
        var updateActiveComponents;
        updateActiveComponents = false;
        this.setContext(settings != null ? settings.context : void 0, updateActiveComponents);
        this.setComponentClassName(settings != null ? settings.componentClassName : void 0);
        this.setTargetPrefix(settings != null ? settings.targetPrefix : void 0);
        this.setWhitelistedOrigins(settings != null ? settings.whitelistedOrigins : void 0);
        if (settings != null ? settings.require : void 0) {
          Vigor.require = (settings != null ? settings.require : void 0) || Vigor.require;
        } else if (typeof require === "function") {
          Vigor.require = require;
        }
        if (settings != null ? settings.componentSettings : void 0) {
          this._parseComponentSettings(settings.componentSettings);
        } else {
          if (settings) {
            this._parseComponentSettings(settings);
          }
        }
        return this;
      };

      ComponentManager.prototype._parseComponentSettings = function(componentSettings) {
        var componentDefinitions, conditions, instanceDefinitions, silent;
        componentDefinitions = componentSettings.components || componentSettings.widgets || componentSettings.componentDefinitions;
        instanceDefinitions = componentSettings.layoutsArray || componentSettings.targets || componentSettings.instanceDefinitions || componentSettings.instances;
        silent = true;
        if (componentSettings.conditions) {
          conditions = componentSettings.conditions;
          if (_.isObject(conditions) && !_.isEmpty(conditions)) {
            this.addConditions(conditions, silent);
          }
        }
        if (componentDefinitions) {
          this._registerComponentDefinitions(componentDefinitions);
        }
        if (instanceDefinitions) {
          this._registerInstanceDefinitions(instanceDefinitions);
        }
        return this;
      };

      ComponentManager.prototype._registerComponentDefinitions = function(componentDefinitions) {
        this._componentDefinitionsCollection.set(componentDefinitions, {
          validate: true,
          parse: true,
          silent: true
        });
        return this;
      };

      ComponentManager.prototype._registerInstanceDefinitions = function(instanceDefinitions) {
        var data;
        data = {
          instanceDefinitions: instanceDefinitions,
          targetPrefix: this.getTargetPrefix()
        };
        this._instanceDefinitionsCollection.set(data, {
          validate: true,
          parse: true,
          silent: true
        });
        return this;
      };

      ComponentManager.prototype._updateActiveComponents = function() {
        var componentClassPromises, deferred, instanceDefinitions, options;
        deferred = $.Deferred();
        options = this._filterModel.get('options');
        instanceDefinitions = this._filterInstanceDefinitions();
        if (options.invert) {
          instanceDefinitions = _.difference(this._instanceDefinitionsCollection.models, instanceDefinitions);
        }
        componentClassPromises = this._componentDefinitionsCollection.getComponentClassPromisesByInstanceDefinitions(instanceDefinitions);
        $.when.apply($, componentClassPromises).then((function(_this) {
          return function() {
            var activeInstanceDefinitionObjs, lastChange, returnData;
            activeInstanceDefinitionObjs = _this._createActiveInstanceDefinitionObjects(instanceDefinitions);
            lastChange = _this._activeInstancesCollection.set(activeInstanceDefinitionObjs, options);
            lastChange = _.filter(lastChange, function(model) {
              return model instanceof ActiveInstanceDefinitionModel;
            });
            _.invoke(lastChange, 'tryToReAddStraysToDom');
            returnData = {
              filter: _this._filterModel.toJSON(),
              activeInstances: _this._mapInstances(_this._activeInstancesCollection.models),
              activeInstanceDefinitions: _this._activeInstancesCollection.toJSON(),
              lastChangedInstances: _this._mapInstances(lastChange),
              lastChangedInstanceDefinitions: _this._modelsToJSON(lastChange)
            };
            return deferred.resolve(returnData);
          };
        })(this));
        return deferred.promise();
      };

      ComponentManager.prototype._createActiveInstanceDefinitionObjects = function(instanceDefinitions) {
        var $context, activeInstanceDefinitionObjs, componentClassName, excludeOptions, options, serializedFilter, targetPrefix, url;
        excludeOptions = true;
        url = this._filterModel.get('url');
        options = this._filterModel.get('options');
        serializedFilter = this._filterModel.serialize(excludeOptions);
        targetPrefix = this.getTargetPrefix();
        componentClassName = this.getComponentClassName();
        $context = this.getContext();
        if (!_.isArray(instanceDefinitions)) {
          instanceDefinitions = [instanceDefinitions];
        }
        activeInstanceDefinitionObjs = _.map(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var activeInstanceObj, componentDefinition, urlParams, urlPattern;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            urlPattern = instanceDefinition.get('urlPattern');
            urlParams = void 0;
            if (urlPattern) {
              urlParams = router.getArguments(urlPattern, url);
            } else {
              urlParams = {
                _id: 'noUrlPatternsDefined',
                url: url
              };
            }
            activeInstanceObj = {
              id: instanceDefinition.id,
              componentClass: componentDefinition.get('componentClass'),
              componentId: componentDefinition.get('id'),
              target: instanceDefinition.getTarget($context),
              targetPrefix: targetPrefix,
              componentClassName: componentClassName,
              instanceArguments: _this._getInstanceArguments(instanceDefinition, componentDefinition),
              order: instanceDefinition.get('order'),
              reInstantiate: instanceDefinition.get('reInstantiate'),
              urlParams: urlParams,
              serializedFilter: serializedFilter
            };
            return activeInstanceObj;
          };
        })(this));
        return activeInstanceDefinitionObjs;
      };

      ComponentManager.prototype._filterInstanceDefinitions = function() {
        var instanceDefinitions;
        instanceDefinitions = this._instanceDefinitionsCollection.models;
        instanceDefinitions = this._filterInstanceDefinitionsByComponentLevelFilters(instanceDefinitions);
        instanceDefinitions = this._filterInstanceDefinitionsByInstanceLevelFilters(instanceDefinitions);
        instanceDefinitions = this._filterInstanceDefinitionsByCustomProperties(instanceDefinitions);
        instanceDefinitions = this._filterInstanceDefinitionsByShowCount(instanceDefinitions);
        instanceDefinitions = this._filterInstanceDefinitionsByTargetAvailability(instanceDefinitions);
        return instanceDefinitions;
      };

      ComponentManager.prototype._filterInstanceDefinitionsByComponentLevelFilters = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var componentDefinition;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            return componentDefinition.passesFilter(_this._filterModel, _this._globalConditionsModel);
          };
        })(this));
      };

      ComponentManager.prototype._filterInstanceDefinitionsByInstanceLevelFilters = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            return instanceDefinition.passesFilter(_this._filterModel, _this._globalConditionsModel);
          };
        })(this));
      };

      ComponentManager.prototype._filterInstanceDefinitionsByCustomProperties = function(instanceDefinitions) {
        var customFilterProperteis;
        customFilterProperteis = this._filterModel.getCustomProperties();
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var componentDefinition, customProperties;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            customProperties = _.extend({}, componentDefinition.getCustomProperties(), instanceDefinition.getCustomProperties());
            if (!_.isEmpty(customFilterProperteis)) {
              return _.isMatch(customProperties, customFilterProperteis);
            } else {
              return true;
            }
          };
        })(this));
      };

      ComponentManager.prototype._filterInstanceDefinitionsByShowCount = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var componentDefinition, componentMaxShowCount;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            componentMaxShowCount = parseInt(componentDefinition.get('maxShowCount', 10));
            return !instanceDefinition.exceedsMaximumShowCount(componentMaxShowCount);
          };
        })(this));
      };

      ComponentManager.prototype._filterInstanceDefinitionsByTargetAvailability = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            return instanceDefinition.isTargetAvailable(_this.getContext());
          };
        })(this));
      };

      ComponentManager.prototype._getInstanceArguments = function(instanceDefinition, componentDefinition) {
        var args, componentArgs, componentClass, instanceArgs;
        componentClass = componentDefinition.get('componentClass');
        args = {};
        componentArgs = componentDefinition.getArgs();
        instanceArgs = instanceDefinition.getArgs();
        if (((componentArgs != null ? componentArgs.iframeAttributes : void 0) != null) && ((instanceArgs != null ? instanceArgs.iframeAttributes : void 0) != null)) {
          instanceArgs.iframeAttributes = _.extend(componentArgs.iframeAttributes, instanceArgs.iframeAttributes);
        }
        _.extend(args, componentArgs, instanceArgs);
        if (componentClass === Vigor.IframeComponent) {
          args.src = componentDefinition.get('src');
        }
        return args;
      };

      ComponentManager.prototype._mapInstances = function(instanceDefinitions) {
        var instances;
        if (!_.isArray(instanceDefinitions)) {
          instanceDefinitions = [instanceDefinitions];
        }
        instanceDefinitions = _.compact(instanceDefinitions);
        instances = _.map(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            return instanceDefinition.get('instance');
          };
        })(this));
        return _.compact(instances);
      };

      ComponentManager.prototype._modelToJSON = function(model) {
        return model.toJSON();
      };

      ComponentManager.prototype._modelsToJSON = function(models) {
        return _.map(models, this._modelToJSON);
      };

      ComponentManager.prototype._onActiveInstanceAdd = function(activeInstanceDefinition) {
        var instanceDefinition;
        instanceDefinition = this._instanceDefinitionsCollection.get(activeInstanceDefinition.id);
        return instanceDefinition.incrementShowCount();
      };

      ComponentManager.prototype._onMessageReceived = function(event) {
        var data, id, message;
        if (!_.isArray(this._whitelistedOrigins)) {
          this._whitelistedOrigins = [this._whitelistedOrigins];
        }
        if (this._whitelistedOrigins.indexOf(event.origin) > -1) {
          data = event.data;
          if (data && data.recipient === COMPONENT_MANAGER_ID) {
            id = data.id;
            message = data.message;
            if (!id) {
              throw this.ERROR.MESSAGE.MISSING_ID;
            }
            if (!message) {
              throw this.ERROR.MESSAGE.MISSING_MESSAGE;
            }
            return this.postMessageToInstance(id, message);
          }
        }
      };

      return ComponentManager;

    })();

    _.extend(ComponentManager.prototype, Backbone.Events);
    Vigor.ComponentManager = ComponentManager;
    Vigor.addRequireReference = (function(_this) {
      return function(req) {
        Vigor.require = req;
        return req;
      };
    })(this);
    Vigor.componentManager = new Vigor.ComponentManager();
    return Vigor;
  });

}).call(this);
