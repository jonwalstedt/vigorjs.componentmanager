var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = {
    initialize: function () {
      Vigor.componentManager.initialize({componentSettings: window.componentSettings});
    }
  };

})(jQuery);
