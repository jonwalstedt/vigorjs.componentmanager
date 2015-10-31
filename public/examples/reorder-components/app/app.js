var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    router: undefined,
    events: {
      'click .decrement': '_onDecrementBtnClick',
      'click .increment': '_onIncrementBtnClick',
      'click .randomize': '_onRandomizeBtnClick',
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        context: this.$el
      });
      Vigor.componentManager.refresh();
    },

    _onDecrementBtnClick: function () {
      var instanceDefinition = Vigor.componentManager.getInstanceById('order-instance-1'),
          order = instanceDefinition.order -= 1;

      if (order < 1) { order = 1; }

      Vigor.componentManager.updateInstances({
        id: 'order-instance-1',
        order: order
      });
    },

    _onIncrementBtnClick: function () {
      var components = Vigor.componentManager.getInstances(),
          instanceDefinition = Vigor.componentManager.getInstanceById('order-instance-1'),
          order = instanceDefinition.order += 1;

      if (order > components.length + 1) { order = components.length + 1; }

      Vigor.componentManager.updateInstances({
        id: 'order-instance-1',
        order: order
      });
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

      Vigor.componentManager.updateInstances(components);
    },

    shuffle: function (o) {
      for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
      return o;
    }
});

})(jQuery);
