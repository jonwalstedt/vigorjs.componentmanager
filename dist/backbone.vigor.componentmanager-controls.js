(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function(root, factory) {
    var Backbone, _;
    if (typeof define === "function" && define.amd) {
      define(['backbone', 'underscore'], function(Backbone, _) {
        return factory(root, Backbone, _);
      });
    } else if (typeof exports === "object") {
      Backbone = require('backbone');
      _ = require('underscore');
      module.exports = factory(root, Backbone, _);
    } else {
      root.Vigor = factory(root, root.Backbone, root._);
    }
  })(this, function(root, Backbone, _) {
    var BaseFormView, ComponentManagerControls, CreateComponentView, DeleteComponentView, RegisterComponentView, UpdateComponentView, Vigor, templateHelper;
    Vigor = Backbone.Vigor = root.Vigor || {};
    templateHelper = {
      addComponentManager: function(componentManager) {
        this.componentManager = componentManager;
      },
      getMainTemplate: function() {
        var markup;
        markup = "<button class='vigorjs-controls__toggle-controls'>Controls</button>\n  \n<div class='vigorjs-controls__header'>\n  <h1 class='vigorjs-controls__title'>Create, update or delete a component or a instance of a component</h1>\n  <button class='vigorjs-controls__show-form-btn' data-target='register'>Component</button>\n  <button class='vigorjs-controls__show-form-btn' data-target='create'>Instance</button>\n<div class='vigorjs-controls__feedback'></div>\n</div>\n  \n<div class='vigorjs-controls__forms'>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__register-wrapper' data-id='register'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__create-wrapper' data-id='create'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__update-wrapper' data-id='update'></div>\n  <div class='vigorjs-controls__wrapper vigorjs-controls__delete-wrapper' data-id='delete'></div>\n</div>\n  ";
        return markup;
      },
      getRegisterTemplate: function(selectedComponent) {
        var componentId, components, conditions, markup, showCount, src;
        components = this.getRegisteredComponents(selectedComponent);
        componentId = (selectedComponent != null ? selectedComponent.id : void 0) || '';
        src = (selectedComponent != null ? selectedComponent.src : void 0) || '';
        showCount = (selectedComponent != null ? selectedComponent.showCount : void 0) || '';
        conditions = '';
        if (_.isString(selectedComponent != null ? selectedComponent.conditions : void 0)) {
          conditions = selectedComponent != null ? selectedComponent.conditions : void 0;
        }
        markup = "<form class='vigorjs-controls__register'>\n  <div class=\"vigorjs-controls__field\">\n    <label for='component-type'>If you want to change a component select one from the dropdown otherwise create a new by filling in the form</label>\n    " + components + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-id'>Unique Component Id</label>\n    <input type='text' id='component-id' placeholder='Unique Component Id' value='" + componentId + "' name='id'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-src'>Component Source - url or namespaced path to view</label>\n    <input type='text' id='component-src' placeholder='Src' value='" + src + "' name='src'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-condition'>Component conditions</label>\n    <input type='text' id='component-condition' placeholder='Conditions' value='" + conditions + "' name='conditions'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-max-showcount'>Component Showcount - Specify if the component should have a maximum instantiation count ex. 1 if it should only be created once per session</label>\n    <input type='text' id='component-max-showcount' placeholder='Max Showcount' value='" + showCount + "' name='maxShowCount'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + (this.getArgumentsFields('Component')) + "\n  </div>\n  \n  <button type='button' class='vigorjs-controls__register-btn'>Save</button>\n</form>";
        return markup;
      },
      getCreateTemplate: function(selectedComponent) {
        var appliedConditions, appliedConditionsMarkup, availableTargets, components, conditions, conditionsMarkup, markup, selectName;
        if (selectedComponent == null) {
          selectedComponent = void 0;
        }
        selectName = 'componentId';
        components = this.getRegisteredComponents(selectedComponent, selectName);
        conditions = this.getRegisteredConditions();
        availableTargets = this.getTargets();
        appliedConditions = this.getAppliedCondition(selectedComponent);
        conditionsMarkup = '';
        appliedConditionsMarkup = '';
        if (conditions) {
          conditionsMarkup = "<p>Available component conditions:</p>\n" + conditions;
        }
        if (appliedConditions) {
          appliedConditionsMarkup = "<p>Already applied conditions:</p>\n" + appliedConditions;
        }
        markup = "<form class='vigorjs-controls__create'>\n  <div class=\"vigorjs-controls__field\">\n    <label for='component-type'>Select component type</label>\n    " + components + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-id'>Instance id - a unique instance id</label>\n    <input type='text' id='component-id' placeholder='id' name='id'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-url-pattern'>Backbone url pattern</label>\n    <input type='text' id='component-url-pattern' placeholder='UrlPattern, ex: /article/:id' name='urlPattern'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + availableTargets + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-order'>Instance order</label>\n    <input type='text' id='component-order' placeholder='Order, ex: 10' name='order'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-reinstantiate'>Reinstantiate component on url param change?</label>\n    <input type='checkbox' name='reInstantiateOnUrlParamChange'>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-filter'>Instance filter - a string that you can use to match against when filtering components</label>\n    <input type='text' id='component-filter' placeholder='Filter' name='filter'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + conditionsMarkup + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + appliedConditionsMarkup + "\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    <label for='component-condition'>Instance conditions</label>\n    <input type='text' id='component-condition' placeholder='Conditions' name='conditions'/>\n  </div>\n  \n  <div class=\"vigorjs-controls__field\">\n    " + (this.getArgumentsFields('Component')) + "\n  </div>\n  \n  <button type='button' class='vigorjs-controls__create-btn'>Create</button>\n</form>";
        return markup;
      },
      getArgumentsFields: function(type) {
        var markup;
        markup = "<label for='component-args'>" + type + " arguments (key:value pairs)</label>\n<div class=\"vigorjs-controls__rows\">\n  " + (this.getArgsRow()) + "\n</div>\n<button type='button' class='vigorjs-controls__remove-row'>remove row</button>\n<button type='button' class='vigorjs-controls__add-row'>add row</button>";
        return markup;
      },
      getRegisteredComponents: function(selectedComponent, selectName) {
        var component, componentDefinitions, j, len, markup, selected;
        if (selectName == null) {
          selectName = 'id';
        }
        componentDefinitions = this.componentManager.getComponents();
        if (componentDefinitions.length > 0) {
          markup = "<select class='vigorjs-controls__component-id' name='" + selectName + "'>";
          markup += '<option value="none-selected" selected="selected">Select a component</option>';
          for (j = 0, len = componentDefinitions.length; j < len; j++) {
            component = componentDefinitions[j];
            selected = '';
            if (selectedComponent && component.id === selectedComponent.id) {
              selected = 'selected="selected"';
            }
            markup += "<option value='" + component.id + "' " + selected + ">" + component.id + "</option>";
          }
          markup += '</select>';
          return markup;
        }
      },
      getRegisteredConditions: function() {
        var condition, conditions, markup;
        conditions = this.componentManager.getConditions();
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
          return componentDefinition = this.componentManager.getComponentById({
            id: selectedComponent
          });
        }
      },
      getTargets: function() {
        var $target, $targets, classSegments, j, k, len, len1, markup, segment, target, targetClasses, targetPrefix;
        targetPrefix = this.componentManager.getTargetPrefix();
        $targets = $("[class*='" + targetPrefix + "']");
        if ($targets.length > 0) {
          markup = '<label for="vigorjs-controls__targets">Select a target for your component</label>';
          markup += '<select id="vigorjs-controls__targets" class="vigorjs-controls__targets" name="targetName">';
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
                target["class"] = "" + segment;
                target.name = segment.replace(targetPrefix + "--", '');
              }
            }
            markup += "<option value='" + target["class"] + "'>" + target.name + "</option>";
          }
          return markup += '</select>';
        }
      },
      getArgsRow: function() {
        var markup;
        markup = "<div class=\"vigorjs-controls__args-row\">\n  <input type='text' placeholder='Key' name='key' class='vigorjs-controls__args-key'/>\n  <input type='text' placeholder='Value' name='value' class='vigorjs-controls__args-val'/>\n</div>";
        return markup;
      }
    };
    BaseFormView = (function(superClass) {
      extend(BaseFormView, superClass);

      function BaseFormView() {
        return BaseFormView.__super__.constructor.apply(this, arguments);
      }

      BaseFormView.prototype.componentManager = void 0;

      BaseFormView.prototype.initialize = function(attributes) {
        return this.componentManager = attributes.componentManager;
      };

      BaseFormView.prototype.parseForm = function($form) {
        var arg, args, definition, i, j, k, len, len1, obj, objs;
        objs = $form.serializeArray();
        definition = {};
        definition.args = {};
        args = [];
        for (i = j = 0, len = objs.length; j < len; i = ++j) {
          obj = objs[i];
          if (obj.name !== 'key' && obj.name !== 'value') {
            definition[obj.name] = obj.value;
          } else {
            args.push(obj);
          }
        }
        for (i = k = 0, len1 = args.length; k < len1; i = ++k) {
          arg = args[i];
          if (i % 2) {
            definition.args[args[i - 1].value] = args[i].value;
          }
        }
        return definition;
      };

      BaseFormView.prototype._onAddRow = function(event) {
        var $btn, $newRow, $rows;
        console.log('_onAddRow');
        $btn = $(event.currentTarget);
        $rows = $('.vigorjs-controls__rows', this.el);
        $newRow = $(templateHelper.getArgsRow());
        return $rows.append($newRow);
      };

      BaseFormView.prototype._onRemoveRow = function(event) {
        var $btn;
        $btn = $(event.currentTarget);
        return $btn.parent().find('.vigorjs-controls__args-row:last').remove();
      };

      return BaseFormView;

    })(Backbone.View);
    RegisterComponentView = (function(superClass) {
      extend(RegisterComponentView, superClass);

      function RegisterComponentView() {
        this._onComponentDefinitionChange = bind(this._onComponentDefinitionChange, this);
        this._onRegister = bind(this._onRegister, this);
        this._onComponentChange = bind(this._onComponentChange, this);
        return RegisterComponentView.__super__.constructor.apply(this, arguments);
      }

      RegisterComponentView.prototype.className = 'vigorjs-controls__register-component';

      RegisterComponentView.prototype.$registerForm = void 0;

      RegisterComponentView.prototype.events = {
        'change .vigorjs-controls__component-id': '_onComponentChange',
        'click .vigorjs-controls__register-btn': '_onRegister',
        'click .vigorjs-controls__add-row': '_onAddRow',
        'click .vigorjs-controls__remove-row': '_onRemoveRow'
      };

      RegisterComponentView.prototype.initialize = function(attributes) {
        RegisterComponentView.__super__.initialize.apply(this, arguments);
        this.componentManager = attributes.componentManager;
        return this.listenTo(this.componentManager, 'component-add component-change component-remove', this._onComponentDefinitionChange);
      };

      RegisterComponentView.prototype.render = function(selectedComponent) {
        this.$el.html(templateHelper.getRegisterTemplate(selectedComponent));
        this.$registerForm = $('.vigorjs-controls__register', this.el);
        this.$componentsDropdown = $('.vigorjs-controls__component-id', this.el);
        return this;
      };

      RegisterComponentView.prototype._registerComponent = function() {
        var componentDefinition, error;
        componentDefinition = this.parseForm(this.$registerForm);
        try {
          this.componentManager.addComponent(componentDefinition);
          this.$registerForm.find('input').val('');
          this.trigger('feedback', 'Component registered');
          return setTimeout((function(_this) {
            return function() {
              return _this.trigger('show', 'create');
            };
          })(this), 1000);
        } catch (_error) {
          error = _error;
          return this.trigger('feedback', error);
        }
      };

      RegisterComponentView.prototype._onComponentChange = function() {
        var componentId, selectedComponent;
        componentId = this.$componentsDropdown.val();
        if (componentId !== 'none-selceted') {
          selectedComponent = this.componentManager.getComponentById(componentId);
          return this.render(selectedComponent);
        }
      };

      RegisterComponentView.prototype._onRegister = function() {
        return this._registerComponent();
      };

      RegisterComponentView.prototype._onComponentDefinitionChange = function() {
        return this.render();
      };

      return RegisterComponentView;

    })(BaseFormView);
    CreateComponentView = (function(superClass) {
      extend(CreateComponentView, superClass);

      function CreateComponentView() {
        this._onTargetChange = bind(this._onTargetChange, this);
        this._onComponentDefinitionChange = bind(this._onComponentDefinitionChange, this);
        return CreateComponentView.__super__.constructor.apply(this, arguments);
      }

      CreateComponentView.prototype.className = 'vigorjs-controls__create-component';

      CreateComponentView.prototype.$createForm = void 0;

      CreateComponentView.prototype.events = {
        'change .vigorjs-controls__targets': '_onTargetChange',
        'click .vigorjs-controls__create-btn': '_onCreateBtnClick',
        'click .vigorjs-controls__add-row': '_onAddRow',
        'click .vigorjs-controls__remove-row': '_onRemoveRow'
      };

      CreateComponentView.prototype.initialize = function(attributes) {
        CreateComponentView.__super__.initialize.apply(this, arguments);
        return this.listenTo(this.componentManager, 'component-add component-change component-remove', this._onComponentDefinitionChange);
      };

      CreateComponentView.prototype.render = function() {
        this.$el.html(templateHelper.getCreateTemplate());
        this.$targets = $('.vigorjs-controls__targets', this.el);
        this.$createForm = $('.vigorjs-controls__create', this.el);
        return this;
      };

      CreateComponentView.prototype._createComponent = function() {
        var error, instanceDefinition;
        instanceDefinition = this.parseForm(this.$createForm);
        console.log('instanceDefinition: ', instanceDefinition);
        try {
          this.componentManager.addInstance(instanceDefinition);
          return this.trigger('feedback', 'Component instantiated');
        } catch (_error) {
          error = _error;
          return this.trigger('feedback', error);
        }
      };

      CreateComponentView.prototype._deselectTargets = function() {
        var $oldTargets;
        $oldTargets = $('.component-area--selected');
        return $oldTargets.removeClass('component-area--selected');
      };

      CreateComponentView.prototype._onComponentDefinitionChange = function() {
        return this.render();
      };

      CreateComponentView.prototype._onTargetChange = function(event) {
        var $option, $target;
        $option = $(event.currentTarget);
        this._deselectTargets();
        $target = $("." + (this.$targets.val()));
        return $target.addClass('component-area--selected');
      };

      CreateComponentView.prototype._onCreateBtnClick = function(event) {
        this._deselectTargets();
        return this._createComponent();
      };

      return CreateComponentView;

    })(BaseFormView);
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

    })(BaseFormView);
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

    })(BaseFormView);
    ComponentManagerControls = (function(superClass) {
      extend(ComponentManagerControls, superClass);

      function ComponentManagerControls() {
        this._onShowFeedback = bind(this._onShowFeedback, this);
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

      ComponentManagerControls.prototype.createComponent = void 0;

      ComponentManagerControls.prototype.updateComponent = void 0;

      ComponentManagerControls.prototype.deleteComponent = void 0;

      ComponentManagerControls.prototype.$wrappers = void 0;

      ComponentManagerControls.prototype.$registerWrapper = void 0;

      ComponentManagerControls.prototype.$createWrapper = void 0;

      ComponentManagerControls.prototype.$updateWrapper = void 0;

      ComponentManagerControls.prototype.$deleteWrapper = void 0;

      ComponentManagerControls.prototype.initialize = function(attributes) {
        this.componentManager = attributes.componentManager;
        templateHelper.addComponentManager(this.componentManager);
        this.render();
        return this._addForms();
      };

      ComponentManagerControls.prototype.render = function() {
        this.$el.empty();
        this.$el.html(templateHelper.getMainTemplate());
        this.$wrappers = $('.vigorjs-controls__wrapper', this.el);
        this.$registerWrapper = $('.vigorjs-controls__register-wrapper', this.el);
        this.$createWrapper = $('.vigorjs-controls__create-wrapper', this.el);
        this.$updateWrapper = $('.vigorjs-controls__update-wrapper', this.el);
        this.$deleteWrapper = $('.vigorjs-controls__delete-wrapper', this.el);
        this.$feedback = $('.vigorjs-controls__feedback', this.el);
        return this;
      };

      ComponentManagerControls.prototype._addForms = function() {
        this.registerComponent = new RegisterComponentView({
          componentManager: this.componentManager
        });
        this.registerComponent.on('show', this._onShow);
        this.registerComponent.on('feedback', this._onShowFeedback);
        this.$registerWrapper.html(this.registerComponent.render().$el);
        this.createComponent = new CreateComponentView({
          componentManager: this.componentManager
        });
        this.createComponent.on('show', this._onShow);
        this.createComponent.on('feedback', this._onShowFeedback);
        this.$createWrapper.html(this.createComponent.render().$el);
        this.updateComponent = new UpdateComponentView({
          componentManager: this.componentManager
        });
        this.updateComponent.on('show', this._onShow);
        this.updateComponent.on('feedback', this._onShowFeedback);
        this.$updateWrapper.html(this.updateComponent.render().$el);
        this.deleteComponent = new DeleteComponentView({
          componentManager: this.componentManager
        });
        this.deleteComponent.on('show', this._onShow);
        this.deleteComponent.on('feedback', this._onShowFeedback);
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

      ComponentManagerControls.prototype._onShowFeedback = function(feedback) {
        this.$feedback.html(feedback);
        return setTimeout((function(_this) {
          return function() {
            return _this.$feedback.empty();
          };
        })(this), 3000);
      };

      return ComponentManagerControls;

    })(Backbone.View);
    Vigor.ComponentManagerControls = ComponentManagerControls;
    return Vigor;
  });

}).call(this);
