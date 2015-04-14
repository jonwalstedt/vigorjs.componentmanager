var app = app || {};

(function ($) {
  'use strict';

  app.ArticleView = Backbone.View.extend({

    template: _.template($('script.article-template').html()),

    initialize: function () {
      console.log('app:ArticleViewd');
      this.render();
    },

    render: function () {
      this.$el.html(this.template());
      return this;
    }

  });

})(jQuery);
