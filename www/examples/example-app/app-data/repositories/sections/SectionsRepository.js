define(function (require) {

  'use strict';

  var SectionsRepository,
      SectionModel = require('./SectionModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      NYTSectionService = require('services/nyt/NYTSectionService');

  SectionsRepository = ServiceRepository.extend({

    ALL: 'all',
    services: {
      'all': NYTSectionService,
    },

    model: SectionModel,

    initialize: function () {
      NYTSectionService.on(NYTSectionService.SECTIONS_RECEIVED, _.bind(this._onSectionsReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    getSectionLabelsByIds: function (ids) {
      if (!_.isArray(ids)) { return; }
      if (ids.length == 0) { return 'all'; }
      return _.compact(_.map(ids, function (id) {
          var section = this.get(id);
          if (section) {
            return section.get('display_name');
          }
        }, this)
      );
    },

    _onSectionsReceived: function (sections) {
      this.set(sections);
    }
  });

  return new SectionsRepository();

});
