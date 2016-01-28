define(function (require) {

  'use strict';

  var ListItemsCollection,
      Backbone = require('backbone');

  ListItemsCollection = Backbone.Collection.extend({

    itemsPerPage: 20,

    paginate: function (index) {
      var startIndex = index * this.itemsPerPage,
          endIndex = (index + 1) * this.itemsPerPage,
          listItems = this.slice(startIndex, endIndex),
          nrOfPages = Math.ceil(this.length / this.itemsPerPage),
          pages = [];

      for (var i = 0; i < nrOfPages; i++) {
        pages.push({
          page: i + 1,
          value: i
        });
      };

      return {
        listItems: _.invoke(listItems, 'toJSON'),
        currentPage: index,
        pages: pages
      }
    }


  });

  return ListItemsCollection
});