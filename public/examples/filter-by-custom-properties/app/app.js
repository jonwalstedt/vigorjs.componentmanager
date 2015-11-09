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
          type = $('input[type="radio"][name="type"]:checked').val(),
          componentStyle = $('input[type="radio"][name="component-style"]:checked').val();

      if (url === 'all')
        url = undefined

      if (type === 'all')
        type = undefined

      if (componentStyle === 'all')
        componentStyle = undefined

      this.filter = {
        componentStyle: componentStyle,
        type: type,
        url: url,
        options: {
          add: this.$addCheckbox.is(':checked'),
          remove: this.$removeCheckbox.is(':checked'),
          merge: this.$mergeCheckbox.is(':checked'),
          invert: this.$invertCheckbox.is(':checked')
        }
      }
    }
  });

})(jQuery);
