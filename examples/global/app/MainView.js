var app = app || {};

(function ($) {
  'use strict';

  app.MainView = Backbone.View.extend({

    className: 'layout layout-main',
    template: _.template($('script.main-template').html()),
    hasRendered: false,

    initialize: function () {
      console.log('app:MainView');
      this.render();
    },

    render: function () {
      if (!this.hasRendered) {
        this.$el.html(this.template());
        this.hasRendered = true;
      }
      return this;
    },

    showSidePanel: function () {
      this.$el.addClass('layout-main--show-sidepanel');
    },

    hideSidePanel: function () {
      this.$el.removeClass('layout-main--show-sidepanel');
    }
  });

})(jQuery);
