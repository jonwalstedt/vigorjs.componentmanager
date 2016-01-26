define(function (require) {

  'use strict';

  var ListItemsCollection,
      Backbone = require('backbone');

  ListItemsCollection = Backbone.Collection.extend({

    itemsPerPage: 20,

    paginate: function (index) {
      var startIndex = index * this.itemsPerPage,
          endIndex = (index + 1) * this.itemsPerPage,
          listItems = this.slice(startIndex, endIndex);

      return {
        listItems: _.invoke(listItems, 'toJSON'),
        currentPage: index,
        nrOfPages: Math.ceil(this.listItems.length / this.itemsPerPage)
      }
    }


  });

  return ListItemsCollection
});