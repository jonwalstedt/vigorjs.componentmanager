(function() {
  var ComponentManagerControls,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ComponentManagerControls = (function(superClass) {
    extend(ComponentManagerControls, superClass);

    function ComponentManagerControls() {
      return ComponentManagerControls.__super__.constructor.apply(this, arguments);
    }

    ComponentManagerControls.prototype.className = 'vigorjs-controls vigorjs-controls--active';

    ComponentManagerControls.prototype.events = {
      'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick',
      'click .vigorjs-controls__add-row': '_onAddRow',
      'click .vigorjs-controls__register-btn': '_onRegister'
    };

    ComponentManagerControls.prototype.initialize = function() {
      return console.log('ComponentManagerControls:initialize');
    };

    ComponentManagerControls.prototype.render = function() {
      this.$el.empty();
      this.$el.html(this.getTemplate());
      return this;
    };

    ComponentManagerControls.prototype.getTemplate = function() {
      var availableComponents, markup;
      availableComponents = Vigor.componentManager.componentDefinitionsCollection.toJSON();
      markup = "<button class='vigorjs-controls__toggle-controls'>Controls</button>\n\n<div class='vigorjs-controls__step vigorjs-controls__select--step-one'>\n  <h1 class='vigorjs-controls__header'>Do you want to register, create, update or delete a component?</h1>\n  <button class='vigorjs-controls__show-register-btn'>Register an iframe component</button>\n  <button class='vigorjs-controls__show-create-btn'>Create</button>\n  <button class='vigorjs-controls__show-update-btn'>Update</button>\n  <button class='vigorjs-controls__show-delete-btn'>Delete</button>\n</div>\n\n<div class='vigorjs-controls__step vigorjs-controls__select--step-two'>\n  <form class='vigorjs-controls__register'>\n    <div class=\"vigorjs-controls__field\">\n      <label for='component-id'>Unique Component Id</label>\n      <input type='text' id='component-id' placeholder='Unique Component Id' name='componentId'/>\n    </div>\n\n    <div class=\"vigorjs-controls__field\">\n      <label for='component-src'>Component Source - url or namespaced path to view</label>\n      <input type='text' id='component-src' placeholder='Src' name='src'/>\n    </div>\n\n    <div class=\"vigorjs-controls__field\">\n      <label for='component-max-showcount'>Component Showcount - Specify if the component should have a maximum instantiation count ex. 1 if it should only be created once per session</label>\n      <input type='text' id='component-max-showcount' placeholder='Max Showcount' name='maxShowCount'/>\n    </div>\n\n    <div class=\"vigorjs-controls__field\">\n      <label for='component-args'>Component arguments (key:value pairs)</label>\n      <div class=\"vigorjs-controls__args-row\">\n        <input type='text' placeholder='Key' name='key' class='vigorjs-controls__args-key'/>\n        <input type='text' placeholder='Value' name='value' class='vigorjs-controls__args-val'/>\n      </div>\n      <button type='button' class='vigorjs-controls__add-row'>add row</button>\n    </div>\n\n    <button type='button' class='vigorjs-controls__register-btn'>Register</button>\n  </form>\n  <div class='vigorjs-controls__step vigorjs-controls__create'></div>\n  <div class='vigorjs-controls__step vigorjs-controls__update'></div>\n  <div class='vigorjs-controls__step vigorjs-controls__delete'></div>\n</div>\n";
      return markup;
    };

    ComponentManagerControls.prototype._onToggleControlsClick = function() {
      return this.$el.toggleClass('vigorjs-controls--active');
    };

    ComponentManagerControls.prototype._onAddRow = function(event) {
      var $btn, $lastRow, $newRow;
      $btn = $(event.currentTarget);
      $lastRow = $btn.parent().find('.vigorjs-controls__args-row:last');
      $newRow = $lastRow.clone();
      $newRow.find('input').val('');
      return $newRow.insertAfter($lastRow);
    };

    ComponentManagerControls.prototype._onRegister = function() {
      var $argRows, $registerForm, $row, componentDefinition, i, len, objs, row;
      $registerForm = $('.vigorjs-controls__register', this.el);
      $argRows = $registerForm.find('.vigorjs-controls__args-row');
      componentDefinition = {};
      componentDefinition.args = {};
      objs = $registerForm.serializeArray();
      for (i = 0, len = $argRows.length; i < len; i++) {
        row = $argRows[i];
        $row = $(row);
        componentDefinition.args[$row.find('.vigorjs-controls__args-key').val()] = $row.find('.vigorjs-controls__args-val').val();
      }
      console.log(componentDefinition);
      componentDefinition = {
        componentId: objs.componentId,
        src: objs.src,
        showcount: objs.showcount
      };
      return console.log(componentDefinition);
    };

    return ComponentManagerControls;

  })(Backbone.View);

  Vigor.ComponentManagerControls = ComponentManagerControls;

}).call(this);
