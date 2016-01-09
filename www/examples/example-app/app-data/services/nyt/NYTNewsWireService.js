define(function (require) {

  'use strict';

  var NYTNewsWireService,
      NYTBaseService = require('./NYTBaseService');

  NYTNewsWireService = NYTBaseService.extend({

    ARTICLES_RECEIVED: 'articles-received',
    APIKey: 'd75403c2e948b8515c11be6c6d8cb36b:2:73508591',

    parse: function (response) {
      // console.log('response: ', response);
      var articles = response.results;

      articles.forEach(function (article) {
        var id = article.title.substr(0, 20).toLowerCase().replace(/\s/g, '_');
        article.id = id;
      });

      NYTBaseService.prototype.parse.call(this, response);
      this.propagateResponse(this.ARTICLES_RECEIVED, articles);
    },

    urlPath: function (model) {
      var url,
          source = 'all',
          section = model.get('section') || 'all',
          timePeriod = model.get('timePeriod') || 24,
          limit = model.get('limit') || 20,
          offset = model.get('offset') || 0;

      url = [source, section, timePeriod].join('/');
      return url + '.json?offset=' + offset + '&limit=' + limit + '&';
    },

    fetch: function (params) {
      var model = this.getModelInstance(params);
      model.fetch({
        success: _.bind(this.onFetchSuccess, this),
        error: _.bind(this.onFetchError, this)
      });
    },

    onFetchError: function (model, jqXHR) {
      if (jqXHR.status === 404) {
        this.propagateResponse(this.FILTERED_ARTICLES_RECEIVED, []);
      }
    },
  });

  return new NYTNewsWireService();
});
