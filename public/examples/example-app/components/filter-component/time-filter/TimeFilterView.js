define(function (require) {

  'use strict';

  var TimeFilterView,
      $ = require('jquery'),
      // _ = require('underscore'),
      Backbone = require('backbone'),
      timeFilterTemplate = require('hbars!./templates/time-filter-template');

  TimeFilterView = Backbone.View.extend({

    className: 'time-filter',

    events: {
      'change .section-filter__time': '_onFilterChange'
    },

    $slider: undefined,
    _renderDeferred: undefined,

    initialize: function () {
      this._renderDeferred = $.Deferred();
    },

    render: function () {
      this.$el.html(timeFilterTemplate({time: this.model.getSelectedTime()}));
      this.$slider = $('.section-filter__time', this.$el);
      this.$sliderValueLabel = $('.section-filter__selected-time', this.$el);
      this._renderDeferred.resolve();
      return this;
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    dispose: function () {
      this.remove();
    },

    _onFilterChange: function (event) {
      var days = $(event.currentTarget).val(), timeObj;
      this.model.set('selectedTime', days);
      timeObj = this.model.getSelectedTime();
      this.$sliderValueLabel.html(timeObj.timeStr);
    }

  });

  return TimeFilterView;

});