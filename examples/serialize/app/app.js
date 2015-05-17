var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    router: undefined,
    events: {
      'click .serialize': '_onSerialiseBtnClick',
      'click .randomize': '_onRandomizeBtnClick',
      'click .save': '_onSaveBtnClick',
    },

    initialize: function () {
      componentSettings = window.localStorage.getItem('componentSettings') || window.componentSettings;

      if (_.isString(componentSettings)) {
      filter = function (key, value) {
        if (value && typeof value === "string"
            && value.substr(0,8) == "function") {
            var startBody = value.indexOf('{') + 1;
            var endBody = value.lastIndexOf('}');
            var startArgs = value.indexOf('(') + 1;
            var endArgs = value.indexOf(')');

           return new Function(value.substring(startArgs, endArgs)
                             , value.substring(startBody, endBody));
          }
          return value;
        }
        componentSettings = JSON.parse(componentSettings, filter);
      }

      Vigor.componentManager.initialize({
        componentSettings: componentSettings,
        $context: this.$el
      });

      this.router = new app.Router();
      Backbone.history.start({root: '/examples/iframe-component/'});
    },

    _onSerialiseBtnClick: function () {
      $('.serialized-output').html(Vigor.componentManager.serialize());
    },

    _onRandomizeBtnClick: function () {
      var components = _.map(Vigor.componentManager.getInstances(), function (instanceDefinition) {
        return {
          id: instanceDefinition.id,
          order: instanceDefinition.order
        }
      }),

      randomOrderArray = [];

      for(var i = 0; i < components.length; i++) {
        randomOrderArray.push(i+1);
      }

      randomOrderArray = this.shuffle(randomOrderArray);

      for(var i = 0; i < components.length; i++) {
        components[i].order = randomOrderArray[i];
      }

      console.log('components: ', components);

      Vigor.componentManager.updateInstances(components);
    },

    _onSaveBtnClick: function () {
      componentSettings = Vigor.componentManager.serialize();
      window.localStorage.setItem('componentSettings', componentSettings)
      $('.serialized-output').html('Current settings saved');
    },

    shuffle: function (o) {
      for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
      return o;
    }
});

})(jQuery);
