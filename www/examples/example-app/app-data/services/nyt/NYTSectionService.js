define(function (require) {

  'use strict';

  var NYTSectionsService,
      NYTBaseService = require('./NYTBaseService');

  NYTSectionsService = NYTBaseService.extend({

    SECTIONS_RECEIVED: 'sections-received',
    APIKey: 'd75403c2e948b8515c11be6c6d8cb36b:2:73508591',

    parse: function (response) {
      var sections = response.results;
      sections.forEach(function (section) {
        section.id = section.section;
      });
      NYTBaseService.prototype.parse.call(this, response);
      this.propagateResponse(this.SECTIONS_RECEIVED, sections);
    },

    urlPath: function (model) {
      return 'section-list.json?'
    }
  });

  return new NYTSectionsService();
});
