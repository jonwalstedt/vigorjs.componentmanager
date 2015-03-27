var app = app || {};

(function ($) {
  'use strict';

  app.HelloWorld = {
    initialize: function () {
      Vigor.componentManager.parseComponentSettings(window.componentSettings);
    }
  };

})(jQuery);
