define(function (require) {

  'use strict';

  var ArticlesRepository,
      ArticleModel = require('./ArticleModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      NYTNewsWireService = require('services/nyt/NYTNewsWireService');

  ArticlesRepository = ServiceRepository.extend({

    NEWS_WIRE: 'newsWire',
    services: {
      'newsWire': NYTNewsWireService
    },

    model: ArticleModel,

    initialize: function () {
      NYTNewsWireService.on(NYTNewsWireService.ARTICLES_RECEIVED, _.bind(this._onArticlesReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    comparator: function (a, b) {
      return new Date(b.get('updated_date')) - new Date(a.get('updated_date'));
    },

    getArticlesBySections: function (sections) {
      if (sections == 'all') { return this.models; }
      return _.flatten(_.map(sections, function (section) {
          return this.getArticlesBySection(section);
        }, this)
      );
    },

    getArticlesBySection: function (section) {
      return this.where({'section': section});
    },

    _onArticlesReceived: function (models) {
      this.set(models, {add: true, remove: false, merge: true});
    }
  });

  return new ArticlesRepository();

});
