define(function (require) {

  'use strict';

  var FileListItemsCollection,
      Backbone = require('backbone');

  FileListItemsCollection = Backbone.Collection.extend({

    itemsPerPage: 10,

    paginate: function (index) {
      var index = parseInt(index, 10),
          startIndex = index * this.itemsPerPage,
          endIndex = (index + 1) * this.itemsPerPage,
          listItems = this.slice(startIndex, endIndex),
          nrOfPages = Math.ceil(this.length / this.itemsPerPage),
          pages = [];

      for (var i = 0; i < nrOfPages; i++) {
        pages.push({
          page: i + 1,
          value: i,
          isActive: i == index
        });
      };

      return {
        listItems: _.invoke(listItems, 'toJSON'),
        currentPage: index,
        pages: pages
      }
    }


  });

  return FileListItemsCollection
});