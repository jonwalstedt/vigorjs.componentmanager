define(function (require) {

  'use strict';

  var HeaderView,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase'),
      headerTemplate = require('hbars!./templates/header-template');

  HeaderView = ComponentViewBase.extend({

    className: 'header-component',

    renderStaticContent: function () {
      this.$el.html(headerTemplate());
      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {},

    addSubscriptions: function () {},

    removeSubscriptions: function () {},

    dispose: function () {
      ComponentViewBase.prototype.dispose.apply(this, arguments);
    }

  });

  return HeaderView;

});
