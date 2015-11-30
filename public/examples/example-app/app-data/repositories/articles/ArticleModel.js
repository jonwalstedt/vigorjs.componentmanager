define(function (require) {

  'use strict';

  var ArticleModel,
      Backbone = require('backbone');

  ArticleModel = Backbone.Model.extend({
    defaults: {
      abstract: undefined,
      byline: undefined,
      created_date: undefined,
      des_facet: undefined,
      geo_facet: undefined,
      item_type: undefined,
      kicker: undefined,
      material_type_facet: undefined,
      multimedia: undefined,
      org_facet: undefined,
      per_facet: undefined,
      published_date: undefined,
      related_urls: undefined,
      section: undefined,
      source: undefined,
      subheadline: undefined,
      subsection: undefined,
      thumbnail_standard: undefined,
      title: undefined,
      updated_date: undefined,
      url: undefined,
    }
  });

  return ArticleModel;

});
