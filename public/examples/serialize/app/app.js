var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({

    events: {
      'click .serialize': '_onSerialiseBtnClick',
      'click .randomize': '_onRandomizeBtnClick',
      'click .save': '_onSaveBtnClick',
      'click .clear': '_onClearBtnClick',
    },

    initialize: function () {
      var stringifiedSettings = window.localStorage.getItem('componentSettings'),
          settings = window.componentSettings;

      if (stringifiedSettings) {
        settings = Vigor.componentManager.parse(stringifiedSettings);
      }

      Vigor.componentManager.initialize(settings);
      Vigor.componentManager.refresh();

    },

    _onSerialiseBtnClick: function () {
      exampleHelpers.showMsg('The componentManager has been serialized - see output below');
      $('.serialized-output').html(Vigor.componentManager.serialize());
    },

    _onRandomizeBtnClick: function () {
      var components = _.map(Vigor.componentManager.getInstanceDefinitions(), function (instanceDefinition) {
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

      Vigor.componentManager.updateInstanceDefinitions(components);
      exampleHelpers.showMsg('Instances has been randomized - try saving them to localStorage and reload');
    },

    _onSaveBtnClick: function () {
      componentSettings = Vigor.componentManager.serialize();
      window.localStorage.setItem('componentSettings', componentSettings)
      exampleHelpers.showMsg('Current settings saved - try to reload the page and see that the order stays the same');
    },

    _onClearBtnClick: function () {
      localStorage.removeItem('componentSettings');
      exampleHelpers.showMsg('localStorage cleared - reload the page');
    },

    shuffle: function (o) {
      for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
      return o;
    }
});

})(jQuery);
