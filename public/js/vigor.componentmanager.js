/**
 * vigorjs.componentmanager - Helps you decouple Backbone applications
 * @version v0.0.4
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
    var ActiveInstancesCollection, BaseCollection, BaseInstanceCollection, ComponentDefinitionModel, ComponentDefinitionsCollection, ComponentManager, FilterModel, IframeComponent, InstanceDefinitionModel, InstanceDefinitionsCollection, Router, Vigor, __testOnly, router;
    Vigor = Backbone.Vigor = root.Vigor || {};
    Vigor.extend = Vigor.extend || Backbone.Model.extend;
    Router = (function(superClass) {
      extend(Router, superClass);

      function Router() {
        return Router.__super__.constructor.apply(this, arguments);
      }

      Router.prototype.getArguments = function(urlPatterns, url) {
        var args, j, len, match, paramsObject, routeRegEx, urlPattern;
        if (!_.isArray(urlPatterns)) {
          urlPatterns = [urlPatterns];
        }
        args = [];
        for (j = 0, len = urlPatterns.length; j < len; j++) {
          urlPattern = urlPatterns[j];
          routeRegEx = this.routeToRegExp(urlPattern);
          match = routeRegEx.test(url);
          if (match) {
            paramsObject = this._getArgumentsFromUrl(urlPattern, url);
            paramsObject.url = url;
            args.push(paramsObject);
          }
        }
        return args;
      };

      Router.prototype.routeToRegExp = function(urlPattern) {
        return this._routeToRegExp(urlPattern);
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
            name = name.replace(':', '').replace('(', '').replace(')', '').replace('*', '').replace('/', '');
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
        includeIfStringMatches: void 0,
        excludeIfStringMatches: void 0,
        hasToMatchString: void 0,
        cantMatchString: void 0,
        options: {
          add: true,
          remove: true,
          merge: true,
          invert: false
        }
      };

      FilterModel.prototype.parse = function(attrs) {
        var props;
        this.clear({
          silent: true
        });
        props = _.extend({}, this.defaults, attrs);
        props.options = _.extend(this.getFilterOptions(), props.options);
        return props;
      };

      FilterModel.prototype.getFilterOptions = function() {
        var add, filter, invert, merge, options, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, remove;
        filter = this.toJSON();
        add = true;
        remove = true;
        merge = true;
        invert = false;
        if ((filter != null ? (ref = filter.options) != null ? ref.add : void 0 : void 0) != null) {
          add = filter != null ? (ref1 = filter.options) != null ? ref1.add : void 0 : void 0;
        }
        if ((filter != null ? (ref2 = filter.options) != null ? ref2.remove : void 0 : void 0) != null) {
          remove = filter != null ? (ref3 = filter.options) != null ? ref3.remove : void 0 : void 0;
        }
        if ((filter != null ? (ref4 = filter.options) != null ? ref4.merge : void 0 : void 0) != null) {
          merge = filter != null ? (ref5 = filter.options) != null ? ref5.merge : void 0 : void 0;
        }
        if ((filter != null ? (ref6 = filter.options) != null ? ref6.invert : void 0 : void 0) != null) {
          invert = filter != null ? (ref7 = filter.options) != null ? ref7.invert : void 0 : void 0;
        }
        options = {
          add: add,
          remove: remove,
          merge: merge,
          invert: invert
        };
        return options;
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

      IframeComponent.prototype.targetOrigin = 'http://localhost:7070';

      function IframeComponent(attrs) {
        this.onIframeLoaded = bind(this.onIframeLoaded, this);
        _.extend(this.attributes, attrs != null ? attrs.iframeAttributes : void 0);
        IframeComponent.__super__.constructor.apply(this, arguments);
      }

      IframeComponent.prototype.initialize = function(attrs) {
        this.addListeners();
        if ((attrs != null ? attrs.src : void 0) != null) {
          return this.src = attrs.src;
        }
      };

      IframeComponent.prototype.addListeners = function() {
        return this.$el.on('load', this.onIframeLoaded);
      };

      IframeComponent.prototype.removeListeners = function() {
        return this.$el.off('load', this.onIframeLoaded);
      };

      IframeComponent.prototype.render = function() {
        return this.$el.attr('src', this.src);
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
        MISSING_GLOBAL_CONDITIONS: 'No global conditions was passed, condition could not be tested',
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
        height: void 0,
        args: void 0,
        conditions: void 0,
        instance: void 0,
        maxShowCount: void 0
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
          throw this.ERROR.NO_CONSTRUCTOR_FOUND(src);
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
                throw this.ERROR.MISSING_GLOBAL_CONDITIONS;
              }
              if (globalConditions[condition] == null) {
                throw this.ERROR.MISSING_CONDITION(condition);
              }
              shouldBeIncluded = !!globalConditions[condition]();
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

      ComponentDefinitionsCollection.prototype.ERROR = {
        UNKNOWN_COMPONENT_DEFINITION: 'Unknown componentDefinition, are you referencing correct componentId?'
      };

      ComponentDefinitionsCollection.prototype.getComponentClassByInstanceDefinition = function(instanceDefinition) {
        var componentDefinition;
        componentDefinition = this.getComponentDefinitionByInstanceDefinition(instanceDefinition);
        return componentDefinition.getClass();
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
          TARGET_NAME_UNDEFINED: 'targetName cant be undefined'
        },
        MISSING_GLOBAL_CONDITIONS: 'No global conditions was passed, condition could not be tested',
        MISSING_RENDER_METHOD: function(id) {
          return "The instance for " + id + " does not have a render method";
        },
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
        instance: void 0,
        showCount: 0,
        urlParams: void 0,
        urlParamsModel: void 0,
        reInstantiateOnUrlParamChange: false,
        filterString: void 0,
        includeIfFilterStringMatches: void 0,
        excludeIfFilterStringMatches: void 0,
        conditions: void 0,
        maxShowCount: void 0,
        urlPattern: void 0
      };

      InstanceDefinitionModel.prototype.validate = function(attrs, options) {
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
      };

      InstanceDefinitionModel.prototype.isAttached = function() {
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
        if ((instance != null ? instance.dispose : void 0) != null) {
          instance.dispose();
        }
        instance = void 0;
        return this.set({
          'instance': void 0
        }, {
          silent: true
        });
      };

      InstanceDefinitionModel.prototype.passesFilter = function(filter, globalConditions) {
        var areConditionsMet, filterStringMatch, urlMatch;
        if ((filter != null ? filter.url : void 0) || (filter != null ? filter.url : void 0) === '') {
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
          areConditionsMet = this.areConditionsMet(globalConditions, filter);
          if (areConditionsMet != null) {
            if (!areConditionsMet) {
              return false;
            }
          }
        }
        if (filter != null ? filter.filterString : void 0) {
          if (this.get('includeIfFilterStringMatches') != null) {
            filterStringMatch = this.includeIfFilterStringMatches(filter.filterString);
            if (filterStringMatch != null) {
              if (!filterStringMatch) {
                return false;
              }
            }
          }
          if (this.get('excludeIfFilterStringMatches') != null) {
            filterStringMatch = this.excludeIfFilterStringMatches(filter.filterString);
            if (filterStringMatch != null) {
              if (!filterStringMatch) {
                return false;
              }
            }
          }
        }
        if (filter != null ? filter.includeIfStringMatches : void 0) {
          filterStringMatch = this.includeIfStringMatches(filter.includeIfStringMatches);
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.excludeIfStringMatches : void 0) {
          filterStringMatch = this.excludeIfStringMatches(filter.excludeIfStringMatches);
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.hasToMatchString : void 0) {
          filterStringMatch = this.hasToMatchString(filter.hasToMatchString);
          if (filterStringMatch != null) {
            if (!filterStringMatch) {
              return false;
            }
          }
        }
        if (filter != null ? filter.cantMatchString : void 0) {
          filterStringMatch = this.cantMatchString(filter.cantMatchString);
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
        maxShowCount = this.get('maxShowCount');
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

      InstanceDefinitionModel.prototype.includeIfStringMatches = function(filterString) {
        var filter;
        filter = this.get('filterString');
        if (filter) {
          return !!filter.match(filterString);
        }
      };

      InstanceDefinitionModel.prototype.excludeIfStringMatches = function(filterString) {
        var filter;
        filter = this.get('filterString');
        if (filter) {
          return !!!filter.match(filterString);
        }
      };

      InstanceDefinitionModel.prototype.hasToMatchString = function(filterString) {
        return !!this.includeIfStringMatches(filterString);
      };

      InstanceDefinitionModel.prototype.cantMatchString = function(filterString) {
        return !!this.excludeIfStringMatches(filterString);
      };

      InstanceDefinitionModel.prototype.includeIfFilterStringMatches = function(filterString) {
        var filter;
        filter = this.get('includeIfFilterStringMatches');
        if (filter) {
          return !!(filterString != null ? filterString.match(filter) : void 0);
        }
      };

      InstanceDefinitionModel.prototype.excludeIfFilterStringMatches = function(filterString) {
        var filter;
        filter = this.get('excludeIfFilterStringMatches');
        if (filter) {
          return !!!(filterString != null ? filterString.match(filter) : void 0);
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
            routeRegEx = router.routeToRegExp(pattern);
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

      InstanceDefinitionModel.prototype.areConditionsMet = function(globalConditions, filter) {
        var condition, instanceConditions, j, len, shouldBeIncluded;
        instanceConditions = this.get('conditions');
        shouldBeIncluded = true;
        if (instanceConditions) {
          if (!_.isArray(instanceConditions)) {
            instanceConditions = [instanceConditions];
          }
          for (j = 0, len = instanceConditions.length; j < len; j++) {
            condition = instanceConditions[j];
            if (_.isFunction(condition) && !condition(filter, this.get('args'))) {
              shouldBeIncluded = false;
              break;
            } else if (_.isString(condition)) {
              if (!globalConditions) {
                throw this.ERROR.MISSING_GLOBAL_CONDITIONS;
              }
              if (globalConditions[condition] == null) {
                throw this.ERROR.MISSING_CONDITION(condition);
              }
              shouldBeIncluded = globalConditions[condition](filter, this.get('args'));
              if (!shouldBeIncluded) {
                break;
              }
            }
          }
        }
        return shouldBeIncluded;
      };

      InstanceDefinitionModel.prototype.addUrlParams = function(url) {
        var matchingUrlParams, urlParamsModel;
        matchingUrlParams = router.getArguments(this.get('urlPattern'), url);
        urlParamsModel = this.get('urlParamsModel');
        if (!urlParamsModel) {
          urlParamsModel = new Backbone.Model();
          this.set({
            'urlParamsModel': urlParamsModel
          }, {
            silent: true
          });
        }
        if (matchingUrlParams.length > 0) {
          urlParamsModel.set(matchingUrlParams[0]);
          return this.set({
            'urlParams': matchingUrlParams
          }, {
            silent: !this.get('reInstantiateOnUrlParamChange')
          });
        }
      };

      InstanceDefinitionModel.prototype.getTargetName = function() {
        var targetName;
        targetName = this.get('targetName');
        if (!(targetName === 'body' || targetName.charAt(0) === '.')) {
          targetName = "." + targetName;
        }
        return targetName;
      };

      return InstanceDefinitionModel;

    })(Backbone.Model);
    BaseInstanceCollection = (function(superClass) {
      extend(BaseInstanceCollection, superClass);

      function BaseInstanceCollection() {
        return BaseInstanceCollection.__super__.constructor.apply(this, arguments);
      }

      BaseInstanceCollection.prototype.ERROR = {
        UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'
      };

      BaseInstanceCollection.prototype.model = InstanceDefinitionModel;

      BaseInstanceCollection.prototype.getInstanceDefinition = function(instanceId) {
        var instanceDefinition;
        instanceDefinition = this.get(instanceId);
        if (!instanceDefinition) {
          throw this.ERROR.UNKNOWN_INSTANCE_DEFINITION;
        }
        return instanceDefinition;
      };

      return BaseInstanceCollection;

    })(BaseCollection);
    InstanceDefinitionsCollection = (function(superClass) {
      extend(InstanceDefinitionsCollection, superClass);

      function InstanceDefinitionsCollection() {
        return InstanceDefinitionsCollection.__super__.constructor.apply(this, arguments);
      }

      InstanceDefinitionsCollection.prototype.getInstanceDefinitions = function(filter, globalConditions) {
        return this.filter(function(instanceDefinitionModel) {
          return instanceDefinitionModel.passesFilter(filter, globalConditions);
        });
      };

      InstanceDefinitionsCollection.prototype.parse = function(data, options) {
        var i, incomingInstanceDefinitions, instanceDefinition, instanceDefinitions, instanceDefinitionsArray, j, k, len, len1, parsedResponse, targetName, targetPrefix, trgtName;
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
                instanceDefinition.targetName = targetPrefix + "--" + targetName;
                this.parseInstanceDefinition(instanceDefinition);
                instanceDefinitionsArray.push(instanceDefinition);
              }
              parsedResponse = instanceDefinitionsArray;
            } else {
              trgtName = incomingInstanceDefinitions.targetName;
              if ((trgtName != null) && trgtName !== 'body' && trgtName.indexOf(targetPrefix) < 0) {
                incomingInstanceDefinitions.targetName = targetPrefix + "--" + trgtName;
              }
              parsedResponse = this.parseInstanceDefinition(incomingInstanceDefinitions);
              break;
            }
          }
        } else if (_.isArray(incomingInstanceDefinitions)) {
          for (i = k = 0, len1 = incomingInstanceDefinitions.length; k < len1; i = ++k) {
            instanceDefinition = incomingInstanceDefinitions[i];
            targetName = instanceDefinition.targetName;
            if ((targetName != null) && targetName !== 'body' && targetName.indexOf(targetPrefix) < 0) {
              instanceDefinition.targetName = targetPrefix + "--" + targetName;
            }
            incomingInstanceDefinitions[i] = this.parseInstanceDefinition(instanceDefinition);
          }
          parsedResponse = incomingInstanceDefinitions;
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

      InstanceDefinitionsCollection.prototype.addUrlParams = function(instanceDefinitions, url) {
        var instanceDefinitionModel, j, len;
        for (j = 0, len = instanceDefinitions.length; j < len; j++) {
          instanceDefinitionModel = instanceDefinitions[j];
          instanceDefinitionModel.addUrlParams(url);
        }
        return instanceDefinitions;
      };

      return InstanceDefinitionsCollection;

    })(BaseInstanceCollection);
    ActiveInstancesCollection = (function(superClass) {
      extend(ActiveInstancesCollection, superClass);

      function ActiveInstancesCollection() {
        return ActiveInstancesCollection.__super__.constructor.apply(this, arguments);
      }

      ActiveInstancesCollection.prototype.getStrays = function() {
        return _.filter(this.models, (function(_this) {
          return function(model) {
            return !model.isAttached();
          };
        })(this));
      };

      return ActiveInstancesCollection;

    })(BaseInstanceCollection);
    ComponentManager = (function() {
      var COMPONENT_CLASS_NAME, TARGET_PREFIX;

      function ComponentManager() {
        this._onMessageReceived = bind(this._onMessageReceived, this);
        this._onActiveInstanceTargetNameChange = bind(this._onActiveInstanceTargetNameChange, this);
        this._onActiveInstanceOrderChange = bind(this._onActiveInstanceOrderChange, this);
        this._onActiveInstanceRemoved = bind(this._onActiveInstanceRemoved, this);
        this._onActiveInstanceChange = bind(this._onActiveInstanceChange, this);
        this._onActiveInstanceAdd = bind(this._onActiveInstanceAdd, this);
        this._updateActiveComponents = bind(this._updateActiveComponents, this);
      }

      COMPONENT_CLASS_NAME = 'vigor-component';

      TARGET_PREFIX = 'component-area';

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

      ComponentManager.prototype.initialize = function(settings) {
        this._componentDefinitionsCollection = new ComponentDefinitionsCollection();
        this._instanceDefinitionsCollection = new InstanceDefinitionsCollection();
        this._activeInstancesCollection = new ActiveInstancesCollection();
        this._globalConditionsModel = new Backbone.Model();
        this._filterModel = new FilterModel();
        this.setComponentClassName();
        this.setTargetPrefix();
        if (settings != null ? settings.listenForMessages : void 0) {
          this._listenForMessages = true;
        }
        this.addListeners();
        this._parse(settings);
        return this;
      };

      ComponentManager.prototype.updateSettings = function(settings) {
        this._parse(settings);
        return this;
      };

      ComponentManager.prototype.refresh = function(filter, cb) {
        var instances;
        if (cb == null) {
          cb = void 0;
        }
        this._filterModel.set(this._filterModel.parse(filter));
        instances = this._mapInstances(this._updateActiveComponents());
        if (cb) {
          cb(filter, instances);
        }
        return this;
      };

      ComponentManager.prototype.serialize = function() {
        var $context, classes, componentSettings, components, conditions, contextSelector, filter, hidden, instanceDefinition, instances, j, len, ref, settings, tagName;
        hidden = [];
        componentSettings = {};
        conditions = this._globalConditionsModel.toJSON();
        components = this._componentDefinitionsCollection.toJSON();
        instances = this._instanceDefinitionsCollection.toJSON();
        for (j = 0, len = instances.length; j < len; j++) {
          instanceDefinition = instances[j];
          instanceDefinition.instance = void 0;
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
            components: components,
            hidden: hidden,
            instances: instances
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
          ref3.clear();
        }
        if ((ref4 = this._globalConditionsModel) != null) {
          ref4.clear();
        }
        this._$context = void 0;
        this._componentClassName = 'vigor-component';
        this._targetPrefix = 'component-area';
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
        this._activeInstancesCollection.on('change:componentId change:filterString change:conditions change:args change:showCount change:urlPattern change:urlParams change:reInstantiateOnUrlParamChange', this._onActiveInstanceChange);
        this._activeInstancesCollection.on('change:order', this._onActiveInstanceOrderChange);
        this._activeInstancesCollection.on('change:targetName', this._onActiveInstanceTargetNameChange);
        this._activeInstancesCollection.on('remove', this._onActiveInstanceRemoved);
        this._componentDefinitionsCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.COMPONENT_ADD, [model.toJSON(), collection.toJSON()]]);
          };
        })(this));
        this._componentDefinitionsCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.COMPONENT_CHANGE, [model.toJSON()]]);
          };
        })(this));
        this._componentDefinitionsCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.COMPONENT_REMOVE, [model.toJSON(), collection.toJSON()]]);
          };
        })(this));
        this._instanceDefinitionsCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.INSTANCE_ADD, [model.toJSON(), collection.toJSON()]]);
          };
        })(this));
        this._instanceDefinitionsCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.INSTANCE_CHANGE, [model.toJSON()]]);
          };
        })(this));
        this._instanceDefinitionsCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.INSTANCE_REMOVE, [model.toJSON(), collection.toJSON()]]);
          };
        })(this));
        this._activeInstancesCollection.on('add', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.ADD, [model.toJSON(), collection.toJSON()]]);
          };
        })(this));
        this._activeInstancesCollection.on('change', (function(_this) {
          return function(model, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.CHANGE, [model.toJSON()]]);
          };
        })(this));
        this._activeInstancesCollection.on('remove', (function(_this) {
          return function(model, collection, options) {
            return _this.trigger.apply(_this, [_this.EVENTS.REMOVE, [model.toJSON(), collection.toJSON()]]);
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

      ComponentManager.prototype.addComponents = function(componentDefinitions) {
        this._componentDefinitionsCollection.set(componentDefinitions, {
          parse: true,
          validate: true,
          remove: false
        });
        return this;
      };

      ComponentManager.prototype.addInstances = function(instanceDefinitions) {
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

      ComponentManager.prototype.updateComponents = function(componentDefinitions) {
        this.addComponents(componentDefinitions);
        return this;
      };

      ComponentManager.prototype.updateInstances = function(instanceDefinitions) {
        this.addInstances(instanceDefinitions);
        return this;
      };

      ComponentManager.prototype.removeComponent = function(componentDefinitionId) {
        this._componentDefinitionsCollection.remove(componentDefinitionId);
        return this;
      };

      ComponentManager.prototype.removeInstance = function(instanceId) {
        this._instanceDefinitionsCollection.remove(instanceId);
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

      ComponentManager.prototype.setContext = function(context) {
        if (context == null) {
          context = 'body';
        }
        if (_.isString(context)) {
          this._$context = $(context);
        } else if (context instanceof $) {
          this._$context = context;
        } else {
          throw this.ERROR.CONTEXT.WRONG_FORMAT;
        }
        return this;
      };

      ComponentManager.prototype.setComponentClassName = function(componentClassName) {
        this._componentClassName = componentClassName || COMPONENT_CLASS_NAME;
        return this;
      };

      ComponentManager.prototype.setTargetPrefix = function(targetPrefix) {
        this._targetPrefix = targetPrefix || TARGET_PREFIX;
        return this;
      };

      ComponentManager.prototype.getContext = function() {
        return this._$context;
      };

      ComponentManager.prototype.getComponentClassName = function() {
        return this._componentClassName;
      };

      ComponentManager.prototype.getTargetPrefix = function() {
        return this._targetPrefix || TARGET_PREFIX;
      };

      ComponentManager.prototype.getActiveFilter = function() {
        return this._filterModel.toJSON();
      };

      ComponentManager.prototype.getConditions = function() {
        return this._globalConditionsModel.toJSON();
      };

      ComponentManager.prototype.getComponentById = function(componentId) {
        return this._componentDefinitionsCollection.getComponentDefinitionById(componentId).toJSON();
      };

      ComponentManager.prototype.getInstanceById = function(instanceId) {
        return this._instanceDefinitionsCollection.getInstanceDefinition(instanceId).toJSON();
      };

      ComponentManager.prototype.getComponents = function() {
        return this._componentDefinitionsCollection.toJSON();
      };

      ComponentManager.prototype.getInstances = function() {
        return this._instanceDefinitionsCollection.toJSON();
      };

      ComponentManager.prototype.getActiveInstances = function() {
        var createNewInstancesIfUndefined;
        createNewInstancesIfUndefined = true;
        return this._mapInstances(this._activeInstancesCollection.models, createNewInstancesIfUndefined);
      };

      ComponentManager.prototype.getActiveInstanceById = function(instanceId) {
        var ref;
        return (ref = this._activeInstancesCollection.getInstanceDefinition(instanceId)) != null ? ref.get('instance') : void 0;
      };

      ComponentManager.prototype.postMessageToInstance = function(id, message) {
        var instance;
        if (!id) {
          throw this.ERROR.MESSAGE.MISSING_ID;
        }
        if (!message) {
          throw this.ERROR.MESSAGE.MISSING_MESSAGE;
        }
        instance = this.getActiveInstanceById(id);
        if (_.isFunction(instance != null ? instance.receiveMessage : void 0)) {
          return instance.receiveMessage(message);
        } else {
          throw this.ERROR.MESSAGE.MISSING_RECEIVE_MESSAGE_METHOD;
        }
      };

      ComponentManager.prototype._parse = function(settings) {
        if (settings != null ? settings.context : void 0) {
          this.setContext(settings.context);
        } else {
          this.setContext($('body'));
        }
        if (settings != null ? settings.componentClassName : void 0) {
          this.setComponentClassName(settings.componentClassName);
        }
        if (settings != null ? settings.targetPrefix : void 0) {
          this.setTargetPrefix(settings.targetPrefix);
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
        var componentDefinitions, conditions, hidden, instanceDefinitions, silent;
        componentDefinitions = componentSettings.components || componentSettings.widgets || componentSettings.componentDefinitions;
        instanceDefinitions = componentSettings.layoutsArray || componentSettings.targets || componentSettings.instanceDefinitions || componentSettings.instances;
        silent = true;
        hidden = componentSettings.hidden;
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

      ComponentManager.prototype._previousElement = function($el, order) {
        if (order == null) {
          order = 0;
        }
        if ($el.length > 0) {
          if ($el.data('order') < order) {
            return $el;
          } else {
            return this._previousElement($el.prev(), order);
          }
        }
      };

      ComponentManager.prototype._updateActiveComponents = function() {
        var filter, instanceDefinitions, options;
        filter = this._filterModel.toJSON();
        options = this._filterModel.getFilterOptions();
        instanceDefinitions = this._filterInstanceDefinitions(filter);
        if (options.invert) {
          instanceDefinitions = _.difference(this._instanceDefinitionsCollection.models, instanceDefinitions);
        }
        this._activeInstancesCollection.set(instanceDefinitions, options);
        this._tryToReAddStraysToDom();
        return instanceDefinitions;
      };

      ComponentManager.prototype._mapInstances = function(instanceDefinitions, createNewInstancesIfUndefined) {
        var instances;
        if (createNewInstancesIfUndefined == null) {
          createNewInstancesIfUndefined = false;
        }
        instances = _.map(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var instance;
            instance = instanceDefinition.get('instance');
            if (createNewInstancesIfUndefined && (instance == null)) {
              _this._addInstanceToModel(instanceDefinition);
              instance = instanceDefinition.get('instance');
            }
            return instance;
          };
        })(this));
        return _.compact(instances);
      };

      ComponentManager.prototype._filterInstanceDefinitions = function(filter) {
        var globalConditions, instanceDefinitions;
        globalConditions = this._globalConditionsModel.toJSON();
        instanceDefinitions = this._instanceDefinitionsCollection.getInstanceDefinitions(filter, globalConditions);
        instanceDefinitions = this._filterInstanceDefinitionsByShowCount(instanceDefinitions);
        instanceDefinitions = this._filterInstanceDefinitionsByConditions(instanceDefinitions);
        return instanceDefinitions;
      };

      ComponentManager.prototype._filterInstanceDefinitionsByShowCount = function(instanceDefinitions) {
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var componentDefinition, componentMaxShowCount;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            componentMaxShowCount = componentDefinition.get('maxShowCount');
            return !instanceDefinition.exceedsMaximumShowCount(componentMaxShowCount);
          };
        })(this));
      };

      ComponentManager.prototype._filterInstanceDefinitionsByConditions = function(instanceDefinitions) {
        var globalConditions;
        globalConditions = this._globalConditionsModel.toJSON();
        return _.filter(instanceDefinitions, (function(_this) {
          return function(instanceDefinition) {
            var componentDefinition;
            componentDefinition = _this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
            return componentDefinition.areConditionsMet(globalConditions);
          };
        })(this));
      };

      ComponentManager.prototype._getInstanceHeight = function(instanceDefinition) {
        var componentDefinition, height;
        componentDefinition = this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
        height = componentDefinition.get('height');
        if (instanceDefinition.get('height')) {
          height = instanceDefinition.get('height');
        }
        return height;
      };

      ComponentManager.prototype._getInstanceArguments = function(instanceDefinition) {
        var args, componentArgs, componentClass, componentDefinition, instanceArgs;
        args = {
          urlParams: instanceDefinition.get('urlParams'),
          urlParamsModel: instanceDefinition.get('urlParamsModel')
        };
        componentDefinition = this._componentDefinitionsCollection.getComponentDefinitionByInstanceDefinition(instanceDefinition);
        componentClass = this._componentDefinitionsCollection.getComponentClassByInstanceDefinition(instanceDefinition);
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
        return args;
      };

      ComponentManager.prototype._addInstanceToModel = function(instanceDefinition) {
        var componentClass, height, instance;
        componentClass = this._componentDefinitionsCollection.getComponentClassByInstanceDefinition(instanceDefinition);
        instance = new componentClass(this._getInstanceArguments(instanceDefinition));
        instance.$el.addClass(this.getComponentClassName());
        if (height = this._getInstanceHeight(instanceDefinition)) {
          instance.$el.css('height', height + "px");
        }
        instanceDefinition.set({
          'instance': instance
        }, {
          silent: true
        });
        return instanceDefinition;
      };

      ComponentManager.prototype._tryToReAddStraysToDom = function() {
        var instance, j, len, ref, render, results, stray;
        ref = this._activeInstancesCollection.getStrays();
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          stray = ref[j];
          render = false;
          if (this._addInstanceToDom(stray, render)) {
            instance = stray.get('instance');
            if ((instance != null ? instance.delegateEvents : void 0) && _.isFunction(instance != null ? instance.delegateEvents : void 0)) {
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

      ComponentManager.prototype._addInstanceToDom = function(instanceDefinition, render) {
        var $target;
        if (render == null) {
          render = true;
        }
        $target = this._getTarget(instanceDefinition);
        if (render) {
          instanceDefinition.renderInstance();
        }
        if ($target.length > 0) {
          this._addInstanceInOrder(instanceDefinition);
          this._setComponentAreaPopulatedState($target);
        }
        return instanceDefinition.isAttached();
      };

      ComponentManager.prototype._addInstanceInOrder = function(instanceDefinition) {
        var $previousElement, $target, instance, order;
        $target = this._getTarget(instanceDefinition);
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
            $previousElement = this._previousElement($target.children().last(), order);
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
            instance.onAddedToDom();
          }
        }
        return this;
      };

      ComponentManager.prototype._isComponentAreaPopulated = function($componentArea) {
        return $componentArea.children().length > 0;
      };

      ComponentManager.prototype._setComponentAreaPopulatedState = function($componentArea) {
        return $componentArea.toggleClass(this._targetPrefix + "--has-components", this._isComponentAreaPopulated($componentArea));
      };

      ComponentManager.prototype._createAndAddInstances = function(instanceDefinitions) {
        var instanceDefinition, j, len;
        if (instanceDefinitions == null) {
          instanceDefinitions = [];
        }
        if (!_.isArray(instanceDefinitions)) {
          instanceDefinitions = [instanceDefinitions];
        }
        for (j = 0, len = instanceDefinitions.length; j < len; j++) {
          instanceDefinition = instanceDefinitions[j];
          this._addInstanceToModel(instanceDefinition);
          this._addInstanceToDom(instanceDefinition);
          instanceDefinition.incrementShowCount();
        }
        return instanceDefinitions;
      };

      ComponentManager.prototype._getTarget = function(instanceDefinition) {
        var $target, targetName;
        targetName = instanceDefinition.getTargetName();
        if (targetName === 'body') {
          $target = $(targetName);
        } else {
          $target = $(targetName, this._$context);
        }
        return $target;
      };

      ComponentManager.prototype._onActiveInstanceAdd = function(instanceDefinition) {
        return this._createAndAddInstances([instanceDefinition]);
      };

      ComponentManager.prototype._onActiveInstanceChange = function(instanceDefinition) {
        var filter, globalConditions;
        filter = this._filterModel.toJSON();
        globalConditions = this._globalConditionsModel.toJSON();
        if (instanceDefinition.passesFilter(filter, globalConditions)) {
          instanceDefinition.disposeInstance();
          this._addInstanceToModel(instanceDefinition);
          return this._addInstanceToDom(instanceDefinition);
        }
      };

      ComponentManager.prototype._onActiveInstanceRemoved = function(instanceDefinition) {
        var $target;
        instanceDefinition.disposeInstance();
        $target = this._getTarget(instanceDefinition);
        return this._setComponentAreaPopulatedState($target);
      };

      ComponentManager.prototype._onActiveInstanceOrderChange = function(instanceDefinition) {
        return this._addInstanceToDom(instanceDefinition);
      };

      ComponentManager.prototype._onActiveInstanceTargetNameChange = function(instanceDefinition) {
        return this._addInstanceToDom(instanceDefinition);
      };

      ComponentManager.prototype._onMessageReceived = function(event) {
        var data, id;
        id = event.data.id;
        data = event.data.data;
        return this.postMessageToInstance(id, data);
      };

      return ComponentManager;

    })();

    _.extend(ComponentManager.prototype, Backbone.Events);
    Vigor.ComponentManager = ComponentManager;
    Vigor.componentManager = new Vigor.ComponentManager();
    return Vigor;
  });

}).call(this);
