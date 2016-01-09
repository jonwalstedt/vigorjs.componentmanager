define(function (require) {

  'use strict';

  var FilterService,
      EventBus = require('vigor').EventBus,
      EventKeys = require('EventKeys'),
      APIService = require('vigor').APIService;

  FilterService = APIService.extend({

    FILTER_RECEIVED: 'filter-received',

    constructor: function () {
      APIService.prototype.constructor.apply(this, arguments);
      EventBus.subscribe(EventKeys.ROUTE_CHANGE, _.bind(this.parse, this));
    },

    parse: function (response) {
      var route = response.route,
          sectionsKey = 'sections',
          timeKey = 'time',
          time = 1,
          filters = [],
          timeIndex = route.indexOf(timeKey + '='),
          sectionIndex = route.indexOf(sectionsKey + '='),
          sectionStr;


      if (timeIndex > 0)
        time = parseInt(route.substr(timeIndex + timeKey.length + 1), 10);

      if (sectionIndex > 0) {
        sectionStr = route.substring(sectionIndex + sectionsKey.length + 1, timeIndex - 1);
        filters = _.map(_.compact(sectionStr.split(';')), function (filter) {
          return {
            id: filter,
            value: filter,
            type: 'section'
          }
        });
      }

      filters.push({
        id: 'time',
        value: time,
        type: 'time'
      });

      this.propagateResponse(this.FILTER_RECEIVED, filters);
    }

  });

  return new FilterService();
});
