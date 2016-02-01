define(function (require) {

  'use strict';

  var FileListItemsCollection,
      Backbone = require('backbone');

  FileListItemsCollection = Backbone.Collection.extend({

    itemsPerPage: 10,

    paginate: function (index, files) {
      var index = parseInt(index, 10),
          startIndex = index * this.itemsPerPage,
          endIndex = (index + 1) * this.itemsPerPage,
          listItems = files.slice(startIndex, endIndex),
          nrOfPages = Math.round(files.length / this.itemsPerPage),
          pages = [];

      for (var i = 0; i < nrOfPages; i++) {
        pages.push({
          page: i + 1,
          value: i,
          isActive: i == (index - 1)
        });
      };

      return {
        listItems: _.invoke(listItems, 'toJSON'),
        currentPage: index,
        pages: pages
      }
    },

    set: function () {
      Backbone.Collection.prototype.set.apply(this, arguments);
      this.trigger('after-set');
    }


  });

  return FileListItemsCollection
});