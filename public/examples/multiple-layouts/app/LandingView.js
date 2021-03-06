var app = app || {};

(function ($) {
  'use strict';

  app.LandingView = Backbone.View.extend({

    className: 'example-layout example-layout-landing',
    template: _.template($('script.landing-template').html()),

    initialize: function () {
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      return this;
    }

  });

})(jQuery);
