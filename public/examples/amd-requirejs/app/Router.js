define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    Vigor = require('vigor'),
    Router = Backbone.Router.extend({
      routes: {
        '*action': '_onAllRoutes',
        '*notFound': '_onAllRoutes'
      },

      _onAllRoutes: function () {
        var filter = {
          url: Backbone.history.fragment
        };

        Vigor.componentManager.refresh(filter);

        if (filter.url == 'add-components'){
          exampleHelpers.showMsg('The matching component - our menu-component (which is a amd package/module is rendered)', Vigor.componentManager._filterModel.toJSON());
        } else {
          exampleHelpers.showMsg('The component does not matches the filter - if it was instantiated it will now be disposed', Vigor.componentManager._filterModel.toJSON());
        }
      }
  });
  return Router;
});
