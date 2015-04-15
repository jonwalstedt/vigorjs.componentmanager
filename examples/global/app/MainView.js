var app = app || {};

(function ($) {
  'use strict';

  app.MainView = Backbone.View.extend({

    className: 'layout layout--main',
    template: _.template($('script.main-template').html()),

    initialize: function () {
      console.log('app:MainView');
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      return this;
    }

  });

})(jQuery);
