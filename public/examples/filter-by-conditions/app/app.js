var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    events: {
      'click .reset': '_onResetClick',
      'click .register-condition': '_onRegisterConditionClick',
      'click .apply-condition-to-component': '_onApplyConditionClick',
      'click .apply-condition-to-instance': '_onApplyConditionToInstanceClick'
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        context: this.$el
      });

      Vigor.componentManager.refresh();

      // Refresh components on resize
      $(window).on('resize', function () {
        Vigor.componentManager.refresh();
      });
    },

    _onResetClick: function () {
      Vigor.componentManager.updateComponents(window.componentSettings.components);
      Vigor.componentManager.updateInstances(window.componentSettings.targets.main);
      showMsg('Components and instances has been reset');
    },

    _onRegisterConditionClick: function () {
      Vigor.componentManager.addConditions({
        correctWidth: function () {
          console.log('correctWidth: ', window.innerWidth > 600);
          return window.innerWidth > 600;
        }
      });
      showMsg('The condition "correctWidth" was registered to the componentManager');
    },

    _onApplyConditionClick: function () {
      try {
        Vigor.componentManager.updateComponents({
          id: 'filter-condition-component',
          conditions: ['correctWidth']
        });
        showMsg('The condition "correctWidth" assigned for all instances of the component "filter-condition-component" - try resizing your browser below 600px width to see the condition in action');
      } catch (error) {
        showMsg('You need to register the condition first - conditions can be added and assigned on the fly.');
      }
    },

    _onApplyConditionToInstanceClick: function () {
      try {
        Vigor.componentManager.updateInstances({
          id: 'filter-instance-2',
          conditions: ['correctWidth']
        });
        showMsg('The condition "correctWidth" the instance with id "filter-instance-2" - try resizing your browser below 600px width to see the condition in action');
      } catch (error) {
        showMsg('You need to register the condition first - conditions can be added and assigned on the fly.');
      }
    }

  });

})(jQuery);
