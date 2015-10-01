var app = app || {};

(function ($) {
  'use strict';

  app.MainView = Backbone.View.extend({

    className: 'example-layout example-layout-main',
    template: _.template($('script.main-template').html()),
    hasRendered: false,

    initialize: function () {
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
      _.defer(_.bind(function () {
        this.$el.addClass('example-layout-main--show-sidepanel');
      }, this));
    },

    hideSidePanel: function () {
      _.defer(_.bind(function () {
        this.$el.removeClass('example-layout-main--show-sidepanel');
      }, this));
    }
  });

})(jQuery);
