(function() {
  var ComponentManagerControls,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ComponentManagerControls = (function(superClass) {
    extend(ComponentManagerControls, superClass);

    function ComponentManagerControls() {
      return ComponentManagerControls.__super__.constructor.apply(this, arguments);
    }

    ComponentManagerControls.prototype.className = 'vigorjs-controls';

    ComponentManagerControls.prototype.events = {
      'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick'
    };

    ComponentManagerControls.prototype.initialize = function() {
      return console.log('ComponentManagerControls:initialize');
    };

    ComponentManagerControls.prototype.render = function() {
      this.$el.empty();
      this.$el.append(this.generateElement({
        tagName: 'button',
        name: 'Create component',
        classes: 'vigorjs-controls__toggle-controls'
      }));
      this.$el.append(this.generateElement({
        tagName: 'select',
        className: 'test',
        options: [
          {
            text: 'option1',
            value: 'val1'
          }, {
            text: 'option2',
            value: 'val2'
          }
        ]
      }));
      this.$el.append(this.generateElement({
        tagName: 'button',
        name: 'Change component'
      }));
      this.$el.append(this.generateElement({
        tagName: 'button',
        name: 'Remove component'
      }));
      return this;
    };

    ComponentManagerControls.prototype.generateElement = function(attrs) {
      var $el, $optionEl, el, i, len, option, optionEl, ref;
      el = document.createElement(attrs.tagName);
      $el = $(el);
      $el.addClass(attrs.classes);
      if (attrs.name) {
        $el.text(attrs.name);
      }
      if (attrs.tagName === 'select') {
        ref = attrs.options;
        for (i = 0, len = ref.length; i < len; i++) {
          option = ref[i];
          optionEl = document.createElement('option');
          $optionEl = $(optionEl);
          $optionEl.html(option.text);
          $optionEl.attr('value', option.value);
          $el.append(optionEl);
        }
      }
      return $el;
    };

    ComponentManagerControls.prototype._onToggleControlsClick = function() {
      return this.$el.toggleClass('vigorjs-controls--active');
    };

    return ComponentManagerControls;

  })(Backbone.View);

  Vigor.ComponentManagerControls = ComponentManagerControls;

}).call(this);
