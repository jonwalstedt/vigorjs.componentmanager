var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    router: undefined,
    events: {
      'click .refresh': '_onRefreshClick',
      'click .register-condition': '_onRegisterConditionClick',
      'click .apply-condition-to-component': '_onApplyConditionClick',
      'click .apply-condition-to-instance': '_onApplyConditionToInstanceClick'
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      this.router = new app.Router();
      Backbone.history.start({root: '/examples/filter-by-url/'});

      // Refresh components on resize
      $(window).on('resize', function () {
        Vigor.componentManager.refresh();
      });
    },

    _onRefreshClick: function () {
      Vigor.componentManager.refresh();
    },

    _onRegisterConditionClick: function () {
      Vigor.componentManager.registerConditions({
        correctWidth: function () {
          console.log('correctWidth: ', window.innerWidth > 600);
          return window.innerWidth > 600;
        }
      });
    },

    _onApplyConditionClick: function () {
      Vigor.componentManager.updateComponents({
        id: 'filter-condition-component',
        conditions: ['correctWidth']
      });
    },

    _onApplyConditionToInstanceClick: function () {
      Vigor.componentManager.updateInstances({
        id: 'filter-instance-2',
        conditions: ['correctWidth']
      });
    }
  });

})(jQuery);
