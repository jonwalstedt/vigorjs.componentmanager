(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
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
    var ComponentManagerControls, CreateComponentView, DeleteComponentView, RegisterComponentView, UpdateComponentView, Vigor, templateHelper;
    Vigor = Backbone.Vigor = root.Vigor || {};
    templateHelper = {
      storeComponentManager: function(componentManager) {
        this.componentManager = componentManager;
      },
      getMainTemplate: function() {
        var markup;
        markup = "<button class='vigorjs-controls__toggle-controls'>Controls</button>\n  \n<div class='vigorjs-controls__header'>\n  <h1 class='vigorjs-controls__title'>Do you want to register, create, update or delete a component?</h1>\n  <button class='vigorjs-controls__show-form-btn' data-target='register'>Register</button>\n  <button class='vigorjs-controls__show-form-btn' data-target='create'>Create</button>\n  <button class='vigorjs-controls__show-form-btn' data-target='update'>Update</button>\n  <button class='vigorjs-controls__show-form-btn' data-target='delete'>Delete</button>\n</div>\n  \n<div class='vigorjs-controls__forms'>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__register-wrapper' data-id='register'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__create-wrapper' data-id='create'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__update-wrapper' data-id='update'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__delete-wrapper' data-id='delete'></div>\n</div>\n  ";
        return markup;
      },
      getCreateTemplate: function(selectedComponent) {
        var appliedConditions, appliedConditionsMarkup, availableTargets, components, conditions, conditionsMarkup, markup;
        if (selectedComponent == null) {
          selectedComponent = void 0;
        }
        components = templateHelper.getRegisteredComponents(selectedComponent);
        conditions = templateHelper.getRegisteredConditions();
        availableTargets = templateHelper.getTargets();
        appliedConditions = templateHelper.getAppliedCondition(selectedComponent);
        conditionsMarkup = '';
        appliedConditionsMarkup = '';
        if (conditions) {
          conditionsMarkup = "<p>Available component conditions:</p>\n" + conditions;
        }
        if (appliedConditions) {
          appliedConditionsMarkup = "<p>Already applied conditions:</p>\n" + appliedConditions;
        }
        markup = "<form class='vigorjs-controls__create'>\n  <div class=\"vigorjs-controls__field\">\n    <label for='component-type'>Select component type</label>\n    " + components + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-id'>Instance id - a unique instance id</label>\n    <input type='text' id='component-id' placeholder='id' name='id'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-url-pattern'>Backbone url pattern</label>\n    <input type='text' id='component-url-pattern' placeholder='UrlPattern, ex: /article/:id' name='urlPattern'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + availableTargets + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-order'>Instance order</label>\n    <input type='text' id='component-order' placeholder='Order, ex: 10' name='order'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-reinstantiate'>Reinstantiate component on url param change?</label>\n    <input type='checkbox' name='reInstantiateOnUrlParamChange'>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-filter'>Instance filter - a string that you can use to match against when filtering components</label>\n    <input type='text' id='component-filter' placeholder='Filter' name='filter'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + conditionsMarkup + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + appliedConditionsMarkup + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-condition'>Instance conditions</label>\n    <input type='text' id='component-condition' placeholder='condition' name='condition'/>\n  </div>\n  \n  <div class='vigorjs-controls__create-feedback'></div>\n  <button type='button' class='vigorjs-controls__create-btn'>Create</button>\n</form>";
        return markup;
      },
      getRegisteredComponents: function(selectedComponent) {
        var component, componentDefinitions, j, len, markup, selected;
        componentDefinitions = this.componentManager.componentDefinitionsCollection.toJSON();
        if (componentDefinitions.length > 0) {
          markup = '<select>';
          markup += "<option value='non-selected' selected='selected'>Select a component type</option>";
          for (j = 0, len = componentDefinitions.length; j < len; j++) {
            component = componentDefinitions[j];
            selected = '';
            if (component.componentId === selectedComponent) {
              selected = 'selected="selected"';
            }
            markup += "<option value='" + component.componentId + "' " + selected + ">" + component.componentId + "</option>";
          }
          markup += '</select>';
          return markup;
        }
      },
      getRegisteredConditions: function() {
        var condition, conditions, markup;
        conditions = this.componentManager.conditions;
        if (!_.isEmpty(conditions)) {
          markup = '';
          for (condition in conditions) {
            markup += "<span>" + condition + " </span>";
          }
          return markup;
        }
      },
      getAppliedCondition: function(selectedComponent) {
        var componentDefinition;
        if (selectedComponent) {
          return componentDefinition = this.componentManager.componentDefinitionsCollection.get({
            id: selectedComponent
          });
        }
      },
      getTargets: function() {
        var $target, $targets, classSegments, j, k, len, len1, markup, segment, target, targetClasses, targetPrefix;
        targetPrefix = this.componentManager.instanceDefinitionsCollection.targetPrefix;
        $targets = $("[class^='" + targetPrefix + "']");
        if ($targets.length > 0) {
          markup = '<label for="vigorjs-controls__targets">Select a target for your component</label>';
          markup += '<select id="vigorjs-controls__targets" class="vigorjs-controls__targets">';
          markup += "<option value='non-selected' selected='selected'>Select a target</option>";
          for (j = 0, len = $targets.length; j < len; j++) {
            target = $targets[j];
            $target = $(target);
            targetClasses = $target.attr('class');
            classSegments = targetClasses.split(' ');
            classSegments = _.without(classSegments, targetPrefix + "--has-component", targetPrefix);
            target = {};
            for (k = 0, len1 = classSegments.length; k < len1; k++) {
              segment = classSegments[k];
              if (segment.indexOf(targetPrefix) > -1) {
                target["class"] = "." + segment;
                target.name = segment.replace(targetPrefix + "--", '');
              }
            }
            markup += "<option value='" + $target["class"] + "'>" + target.name + "</option>";
          }
          return markup += '</select>';
        }
      }
    };
    RegisterComponentView = (function(superClass) {
      extend(RegisterComponentView, superClass);

      function RegisterComponentView() {
        this._onRegister = bind(this._onRegister, this);
        return RegisterComponentView.__super__.constructor.apply(this, arguments);
      }

      RegisterComponentView.prototype.className = 'vigorjs-controls__register-component';

      RegisterComponentView.prototype.events = {
        'click .vigorjs-controls__remove-row': '_onRemoveRow',
        'click .vigorjs-controls__add-row': '_onAddRow',
        'click .vigorjs-controls__register-btn': '_onRegister'
      };

      RegisterComponentView.prototype.componentManager = void 0;

      RegisterComponentView.prototype.$feedback = void 0;

      RegisterComponentView.prototype.initialize = function(attributes) {
        return this.componentManager = attributes.componentManager;
      };

      RegisterComponentView.prototype.render = function() {
        this.$el.empty();
        this.$el.html(this.getTemplate());
        this.$feedback = $('.vigorjs-controls__register-feedback', this.el);
        return this;
      };

      RegisterComponentView.prototype.getTemplate = function() {
        var availableComponents, markup;
        availableComponents = this.componentManager.componentDefinitionsCollection.toJSON();
        markup = "<form class='vigorjs-controls__register'>\n  <div class=\"vigorjs-controls__field\">\n    <label for='component-id'>Unique Component Id</label>\n    <input type='text' id='component-id' placeholder='Unique Component Id' name='componentId'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-src'>Component Source - url or namespaced path to view</label>\n    <input type='text' id='component-src' placeholder='Src' name='src'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-max-showcount'>Component Showcount - Specify if the component should have a maximum instantiation count ex. 1 if it should only be created once per session</label>\n    <input type='text' id='component-max-showcount' placeholder='Max Showcount' name='maxShowCount'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-args'>Component arguments (key:value pairs)</label>\n    <div class=\"vigorjs-controls__rows\">\n      " + (this.getRow()) + "\n    </div>\n    <button type='button' class='vigorjs-controls__remove-row'>remove row</button>\n    <button type='button' class='vigorjs-controls__add-row'>add row</button>\n  </div>\n  \n  <div class='vigorjs-controls__register-feedback'></div>\n  <button type='button' class='vigorjs-controls__register-btn'>Register</button>\n</form>";
        return markup;
      };

      RegisterComponentView.prototype.getRow = function() {
        var markup;
        markup = "<div class=\"vigorjs-controls__args-row\">\n  <input type='text' placeholder='Key' name='key' class='vigorjs-controls__args-key'/>\n  <input type='text' placeholder='Value' name='value' class='vigorjs-controls__args-val'/>\n</div>";
        return markup;
      };

      RegisterComponentView.prototype._registerComponent = function() {
        var $argRows, $registerForm, arg, args, componentDefinition, error, i, j, k, len, len1, obj, objs;
        $registerForm = $('.vigorjs-controls__register', this.el);
        $argRows = $registerForm.find('.vigorjs-controls__args-row');
        componentDefinition = {};
        componentDefinition.args = {};
        objs = $registerForm.serializeArray();
        args = [];
        for (i = j = 0, len = objs.length; j < len; i = ++j) {
          obj = objs[i];
          if (obj.name !== 'key' && obj.name !== 'value') {
            componentDefinition[obj.name] = obj.value;
          } else {
            args.push(obj);
          }
        }
        for (i = k = 0, len1 = args.length; k < len1; i = ++k) {
          arg = args[i];
          if (i % 2) {
            componentDefinition.args[args[i - 1].value] = args[i].value;
          }
        }
        try {
          this.componentManager.addComponentDefinition(componentDefinition);
          $registerForm.find('input').val('');
          this._showFeedback('Component registered');
          return setTimeout((function(_this) {
            return function() {
              return _this.trigger('show', 'create');
            };
          })(this), 1000);
        } catch (_error) {
          error = _error;
          return this._showFeedback(error);
        }
      };

      RegisterComponentView.prototype._showFeedback = function(feedback) {
        return this.$feedback.html(feedback);
      };

      RegisterComponentView.prototype._onAddRow = function(event) {
        var $btn, $newRow, $rows;
        $btn = $(event.currentTarget);
        $rows = $('.vigorjs-controls__rows', this.el);
        $newRow = $(this.getRow());
        return $rows.append($newRow);
      };

      RegisterComponentView.prototype._onRemoveRow = function(event) {
        var $btn;
        $btn = $(event.currentTarget);
        return $btn.parent().find('.vigorjs-controls__args-row:last').remove();
      };

      RegisterComponentView.prototype._onRegister = function() {
        return this._registerComponent();
      };

      return RegisterComponentView;

    })(Backbone.View);
    CreateComponentView = (function(superClass) {
      extend(CreateComponentView, superClass);

      function CreateComponentView() {
        this._onChange = bind(this._onChange, this);
        this._onComponentDefinitionChange = bind(this._onComponentDefinitionChange, this);
        return CreateComponentView.__super__.constructor.apply(this, arguments);
      }

      CreateComponentView.prototype.className = 'vigorjs-controls__create-component';

      CreateComponentView.prototype.events = {
        'change .vigorjs-controls__targets': '_onChange'
      };

      CreateComponentView.prototype.componentManager = void 0;

      CreateComponentView.prototype.$feedback = void 0;

      CreateComponentView.prototype.initialize = function(attributes) {
        this.componentManager = attributes.componentManager;
        return this.listenTo(this.componentManager.componentDefinitionsCollection, 'change add remove', this._onComponentDefinitionChange);
      };

      CreateComponentView.prototype.render = function() {
        this.$el.empty();
        this.$el.html(templateHelper.getCreateTemplate());
        this.$feedback = $('.vigorjs-controls__create-feedback', this.el);
        return this;
      };

      CreateComponentView.prototype._onComponentDefinitionChange = function() {
        return this.render();
      };

      CreateComponentView.prototype._onChange = function(event) {
        return console.log(event);
      };

      return CreateComponentView;

    })(Backbone.View);
    UpdateComponentView = (function(superClass) {
      extend(UpdateComponentView, superClass);

      function UpdateComponentView() {
        return UpdateComponentView.__super__.constructor.apply(this, arguments);
      }

      UpdateComponentView.prototype.className = 'vigorjs-controls__update-component';

      UpdateComponentView.prototype.componentManager = void 0;

      UpdateComponentView.prototype.$feedback = void 0;

      UpdateComponentView.prototype.initialize = function(attributes) {
        return this.componentManager = attributes.componentManager;
      };

      UpdateComponentView.prototype.render = function() {
        this.$el.empty();
        this.$el.html(this.getTemplate());
        this.$feedback = $('.vigorjs-controls__update-feedback', this.el);
        return this;
      };

      UpdateComponentView.prototype.getTemplate = function() {
        var markup;
        markup = "<form class='vigorjs-controls__update'>\n  <div class='vigorjs-controls__update-feedback'></div>\n  <button type='button' class='vigorjs-controls__update-btn'>Create</button>\n</form>";
        return markup;
      };

      return UpdateComponentView;

    })(Backbone.View);
    DeleteComponentView = (function(superClass) {
      extend(DeleteComponentView, superClass);

      function DeleteComponentView() {
        return DeleteComponentView.__super__.constructor.apply(this, arguments);
      }

      DeleteComponentView.prototype.className = 'vigorjs-controls__delete-component';

      DeleteComponentView.prototype.componentManager = void 0;

      DeleteComponentView.prototype.$feedback = void 0;

      DeleteComponentView.prototype.initialize = function(attributes) {
        return this.componentManager = attributes.componentManager;
      };

      DeleteComponentView.prototype.render = function() {
        this.$el.empty();
        this.$el.html(this.getTemplate());
        this.$feedback = $('.vigorjs-controls__deltete-feedback', this.el);
        return this;
      };

      DeleteComponentView.prototype.getTemplate = function() {
        var markup;
        markup = "<form class='vigorjs-controls__delete'>\n  <div class='vigorjs-controls__delete-feedback'></div>\n  <button type='button' class='vigorjs-controls__delete-btn'>Delete</button>\n</form>";
        return markup;
      };

      return DeleteComponentView;

    })(Backbone.View);
    ComponentManagerControls = (function(superClass) {
      extend(ComponentManagerControls, superClass);

      function ComponentManagerControls() {
        this._onShow = bind(this._onShow, this);
        this._onShowFormBtnClick = bind(this._onShowFormBtnClick, this);
        return ComponentManagerControls.__super__.constructor.apply(this, arguments);
      }

      ComponentManagerControls.prototype.className = 'vigorjs-controls vigorjs-controls--active';

      ComponentManagerControls.prototype.events = {
        'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick',
        'click .vigorjs-controls__show-form-btn': '_onShowFormBtnClick'
      };

      ComponentManagerControls.prototype.componentManager = void 0;

      ComponentManagerControls.prototype.registerComponent = void 0;

      ComponentManagerControls.prototype.$formWrapper = void 0;

      ComponentManagerControls.prototype.initialize = function(attributes) {
        this.componentManager = attributes.componentManager;
        return templateHelper.storeComponentManager(this.componentManager);
      };

      ComponentManagerControls.prototype.render = function() {
        this.$el.empty();
        this.$el.html(templateHelper.getMainTemplate());
        this.$wrappers = $('.vigorjs-controls__wrapper', this.el);
        this.$registerWrapper = $('.vigorjs-controls__register-wrapper', this.el);
        this.$createWrapper = $('.vigorjs-controls__create-wrapper', this.el);
        this.$updateWrapper = $('.vigorjs-controls__update-wrapper', this.el);
        this.$deleteWrapper = $('.vigorjs-controls__delete-wrapper', this.el);
        this._addRegisterForm();
        this._addCreateForm();
        this._addUpdateForm();
        this._addDeleteForm();
        return this;
      };

      ComponentManagerControls.prototype._addRegisterForm = function() {
        this.registerComponent = new RegisterComponentView({
          componentManager: this.componentManager
        });
        this.registerComponent.on('show', this._onShow);
        return this.$registerWrapper.html(this.registerComponent.render().$el);
      };

      ComponentManagerControls.prototype._addCreateForm = function() {
        this.createComponent = new CreateComponentView({
          componentManager: this.componentManager
        });
        this.createComponent.on('show', this._onShow);
        return this.$createWrapper.html(this.createComponent.render().$el);
      };

      ComponentManagerControls.prototype._addUpdateForm = function() {
        this.updateComponent = new UpdateComponentView({
          componentManager: this.componentManager
        });
        this.updateComponent.on('show', this._onShow);
        return this.$updateWrapper.html(this.updateComponent.render().$el);
      };

      ComponentManagerControls.prototype._addDeleteForm = function() {
        this.deleteComponent = new DeleteComponentView({
          componentManager: this.componentManager
        });
        this.deleteComponent.on('show', this._onShow);
        return this.$deleteWrapper.html(this.deleteComponent.render().$el);
      };

      ComponentManagerControls.prototype._showWrapper = function(targetName) {
        var $target;
        this.$wrappers.removeClass('vigorjs-controls__wrapper--show');
        $target = this.$wrappers.filter("[data-id='" + targetName + "']");
        return $target.addClass('vigorjs-controls__wrapper--show');
      };

      ComponentManagerControls.prototype._onToggleControlsClick = function() {
        return this.$el.toggleClass('vigorjs-controls--active');
      };

      ComponentManagerControls.prototype._onShowFormBtnClick = function(event) {
        var $btn, targetName;
        $btn = $(event.currentTarget);
        targetName = $btn.data('target');
        return this._showWrapper(targetName);
      };

      ComponentManagerControls.prototype._onShow = function(targetName) {
        return this._showWrapper(targetName);
      };

      return ComponentManagerControls;

    })(Backbone.View);
    Vigor.ComponentManagerControls = ComponentManagerControls;
    return Vigor;
  });

}).call(this);
