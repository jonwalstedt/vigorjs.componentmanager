define(function (require) {

  'use strict';

  var ServiceBase,
      APIService = require('vigor').APIService;

  ServiceBase = APIService.extend({

    urlPath: '',
    _baseUrl: 'http://localhost:4000/',
    _isGHPages: false,

    constructor: function () {
      APIService.prototype.constructor.apply(this, arguments);
      this._isGHPages = this._window.location.hostname.indexOf('github') > -1;

      if (this._isGHPages) {
        this._baseUrl = '/examples/example-app/';
      }
    },

    url: function (model) {
      return this._baseUrl + this.getUrlPath(model);
    },

    getUrlPath: function (model) {
      if (this._isGHPages) {
        return 'mock-data/json-db-dump.json';
      } else {
        return this.urlPath;
      }
    }

  });

  return ServiceBase;
});