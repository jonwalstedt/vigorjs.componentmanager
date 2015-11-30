define(function (require) {

  'use strict';

  var NYTBaseService,
      APIService = require('vigor').APIService;

  NYTBaseService = APIService.extend({

    _baseUrl: 'http://api.nytimes.com/svc/news/v3/content/',

    url: function (model) {
      return this._baseUrl + this.urlPath(model) + this.getAPIKey();
    },

    // Override me
    urlPath: function (model) {
      return '';
    },

    getAPIKey: function () {
      return 'api-key=' + this.APIKey;
    }

  });

  return NYTBaseService;

});
