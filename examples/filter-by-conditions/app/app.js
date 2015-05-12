var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    router: undefined,
    events: {
      'click .refresh': '_onRefreshClick',
      'click .register-condition-a': '_onRegisterConditionAClick',
      'click .apply-condition-a': '_onApplyConditionAClick',
      'click .apply-condition-a-to-instance': '_onApplyConditionAToInstanceClick'
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        $context: this.$el
      });

      this.router = new app.Router();
      Backbone.history.start({root: '/examples/filter-by-url/'});

      // Refresh components on resize
      // $(window).on('resize', function () {
      //   Vigor.componentManager.refresh();
      // });
    },

    _onRefreshClick: function () {
      Vigor.componentManager.refresh();
    },

    _onRegisterConditionAClick: function () {
      Vigor.componentManager.registerConditions({
        correctWidth: function () {
          console.log('correctWidth: ', window.innerWidth > 600);
          return window.innerWidth > 600;
        }
      });
      console.log('current conditions: ', Vigor.componentManager.getConditions());
    },

    _onApplyConditionAClick: function () {
      Vigor.componentManager.updateComponent('filter-instance', {
        conditions: ['correctWidth']
      });
      console.log(Vigor.componentManager.getComponentById('filter-instance'));
    },

    _onApplyConditionAToInstanceClick: function () {
      Vigor.componentManager.updateInstance('filter-instance-2', {
        conditions: ['correctWidth']
      });
    }


  });

})(jQuery);
