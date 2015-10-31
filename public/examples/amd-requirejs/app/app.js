define (function (require) {
  'use strict';
  var MainLayoutView = require('app/MainLayoutView'),

      // Components has to be required priror to initialization of the
      // componentManager - no lazy loading :(
      Menu = require('components/menu');

  new MainLayoutView({
    el: '.app-wrapper'
  });
});