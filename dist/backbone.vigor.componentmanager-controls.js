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
      'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'
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
      markup = "<button class='vigorjs-controls__toggle-controls'>Controls</button>\n\n<div class='vigorjs-controls__step vigorjs-controls__select--step-one'>\n  <h1 class='vigorjs-controls__header'>Do you want to create, update or delete a component?</h1>\n  <button class='vigorjs-controls__create'>Create</button>\n  <button class='vigorjs-controls__update'>Update</button>\n  <button class='vigorjs-controls__delete'>Delete</button>\n</div>\n\n<div class='vigorjs-controls__step vigorjs-controls__select--step-two'>\n  <div class='vigorjs-controls__step vigorjs-controls__create'>\n\n  </div>\n  <div class='vigorjs-controls__step vigorjs-controls__update'>\n  </div>\n  <div class='vigorjs-controls__step vigorjs-controls__delete'>\n  </div>\n</div>\n";
      return markup;
    };

    ComponentManagerControls.prototype._onToggleControlsClick = function() {
      return this.$el.toggleClass('vigorjs-controls--active');
    };

    return ComponentManagerControls;

  })(Backbone.View);

  Vigor.ComponentManagerControls = ComponentManagerControls;

}).call(this);
