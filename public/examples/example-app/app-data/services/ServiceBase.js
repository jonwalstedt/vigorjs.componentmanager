define(function (require) {

  'use strict';

  var ServiceBase,
      APIService = require('vigor').APIService;

  ServiceBase = APIService.extend({

    _baseUrl: 'http://localhost:4000/',

    url: function (model) {
      return this._baseUrl + this.urlPath(model);
    },

    // Override me
    urlPath: function (model) {
      return '';
    }

  });

  return ServiceBase;
});