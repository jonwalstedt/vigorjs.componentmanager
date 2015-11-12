var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    events: {
      'click .refresh': '_onRefreshClick',
      'change .options input': '_updateFilter',
    },

    filter: undefined,

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        context: this.$el
      });

      this.$addCheckbox = $('.add', this.$el);
      this.$removeCheckbox = $('.remove', this.$el);
      this.$mergeCheckbox = $('.merge', this.$el);
      this.$invertCheckbox = $('.invert', this.$el);
      this.$forceFilterStringMatching = $('.force-filter-string-matching', this.$el);

      Vigor.componentManager.refresh();
      this._updateFilter();
      showMsg('Components Refreshed', this.filter);
    },

    _onRefreshClick: function () {
      Vigor.componentManager.refresh(this.filter);
      showMsg('Components filtered', this.filter);
    },

    _updateFilter: function () {
      var url = $('input[type="radio"][name="url"]:checked').val(),
          filterString = $('input[type="radio"][name="filter-string"]:checked').val();

      if (url === "all")
        url = undefined

      if (filterString === "none")
        filterString = undefined

      this.filter = {
        url: url,
        includeIfMatch: filterString,
        options: {
          add: this.$addCheckbox.is(':checked'),
          remove: this.$removeCheckbox.is(':checked'),
          merge: this.$mergeCheckbox.is(':checked'),
          invert: this.$invertCheckbox.is(':checked'),
          forceFilterStringMatching: this.$forceFilterStringMatching.is(':checked')
        }
      }
    }
  });

})(jQuery);
