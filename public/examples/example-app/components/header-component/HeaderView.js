define(function (require) {

  'use strict';

  var HeaderView,
      $ = require('jquery'),
      ComponentViewBase = require('components/ComponentViewBase');

  HeaderView = ComponentViewBase.extend({

    className: 'header-component',
    componentName: 'header',
    template: _.template($('script.header-template').html()),

    renderStaticContent: function () {
      this.$el.html(this.template());
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
