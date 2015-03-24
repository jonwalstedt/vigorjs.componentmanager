console.log('im the app');
var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = {
    initialize: function () {
      var components = [
        {
          id: 'vigor-navigation',
          urlPattern: '*',
          filter: undefined,
          path: 'window.TestView',
          target: 'body'
        },
        {
          id: 'vigor-gallery',
          urlPattern: '/gallery',
          filter: undefined,
          path: 'window.TestGallery',
          target: 'body'
        }
      ];
      Vigor.componentManager.registerComponents(components);
    }
  };

})(jQuery);
