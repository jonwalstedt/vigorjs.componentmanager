var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    $el: undefined,
    mainView: undefined,
    articleView: undefined,

    routes: {
      'article/:id': '_onArticleRoute',
      '*action': '_onAllOtherRoutes'
    },

    initialize: function (options) {
      this.$el = options.$container;
      this.mainView = new app.MainView();
      this.articleView = new app.ArticleView();
    },

    _onArticleRoute: function (id) {
      this.$el.html(this.articleView.render().$el);
      this._refreshComponents();
    },

    _onAllOtherRoutes: function () {
      this.$el.html(this.mainView.render().$el);
      this._refreshComponents();
    },

    _refreshComponents: function () {
      var filterOptions = {
        route: Backbone.history.fragment
      };
      Vigor.componentManager.refresh(filterOptions);
    }
  });

})(jQuery);
