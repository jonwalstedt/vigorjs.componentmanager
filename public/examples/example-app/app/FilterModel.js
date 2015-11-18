define(function (require) {
  'use strict';

  var FilterModel,
      _ = require('underscore'),
      Backbone = require('backbone');

  FilterModel = Backbone.Model.extend({

    defaults: {
      preload: true
    },

    resetAndSet: function (attributes, options) {
      var defaultOptions = {
        add: true,
        remove: true,
        merge: true,
        invert: false,
        forceFilterStringMatching: false
      },
      url = this.get('url'),
      preload = this.get('preload'),
      filterOptions = _.extend(defaultOptions, attributes.options);

      if (!this._hasValue(attributes.url)) {
        attributes.url = url;
      }

      if (!this._hasValue(attributes.preload)) {
        if (!this._hasValue(preload)) {
          attributes.preload = true;
        }
        attributes.preload = preload;
      }

      attributes.options = filterOptions;

      this.clear({silent: true});
      this.set(attributes, options);
    },

    _hasValue: function (value) {
      return !(_.isUndefined(value) || _.isNull(value));
    }

  });

  return new FilterModel();
});
