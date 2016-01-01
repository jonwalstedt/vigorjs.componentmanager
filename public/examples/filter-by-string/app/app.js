var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({
    forceFilterStringMatching: false,
    events: {
      'click .restore': 'restore',
      'click .include-if-string-matches': 'includeIfMatch',
      'click .exclude-if-string-matches': 'excludeIfMatch',
      'click .has-to-match-string': 'hasToMatch',
      'click .cant-match-string': 'cantMatch',
      'click .update-filter-string-lang-en-gb': 'updateFilterStringLangEnGB',
      'click .update-filter-string-lang-sv-se': 'updateFilterStringLangSvSE',
      'click .update-filter-string-url': 'updateFilterStringUrl',
      'change .controls input': 'toggleForcedFilterStringMatching'
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        context: this.$el
      });
      this.$forceFilterStringMatching = $('.force-filter-string-matching', this.$el);
      this.restore();
    },

    restore: function () {
      Vigor.componentManager.refresh();
      this.forceFilterStringMatching = false;
      this.$forceFilterStringMatching.attr('checked', false);
      exampleHelpers.showMsg('Click links above to see examples of filtering using a filterString');
    },

    // examples where the filterString is set on the instanceDefinition
    includeIfMatch: function () {
      var
        filter = {
          includeIfMatch: 'first',
          options: {
            forceFilterStringMatching: this.forceFilterStringMatching
          }
        },
        msg = 'includeIfMatch - will show instanceDefinitions that has a filterString that matches <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined (unless forceFilterStringMatching is set to true)';
      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

    excludeIfMatch: function () {
      var
        filter = {
          excludeIfMatch: 'first',
          options: {
            forceFilterStringMatching: this.forceFilterStringMatching
          }
        },
        msg = 'excludeIfMatch - will show instanceDefinitions that has a filterString that does <b>not</b> match <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined (unless forceFilterStringMatching is set to true)';

      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

    hasToMatch: function () {
      var
        filter = {
          hasToMatch: 'first',
          options: {
            forceFilterStringMatching: this.forceFilterStringMatching
          }
        },
        msg = 'hasToMatch - will filter instanceDefinitions to only show instances that has a filterString that matches <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';

      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

    cantMatch: function () {
      var
        filter = {
          cantMatch: 'first',
          options: {
            forceFilterStringMatching: this.forceFilterStringMatching
          }
        },
        msg = 'cantMatch - will filter instanceDefinitions to only show instances that has a filterString that does <b>not</b> match <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';
      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

    toggleForcedFilterStringMatching: function () {
      var filter = Vigor.componentManager.getActiveFilter(),
          msg = 'toggleForcedFilterStringMatching has been toggled';
      this.forceFilterStringMatching = !this.forceFilterStringMatching;
      filter.options.forceFilterStringMatching = this.forceFilterStringMatching;
      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

    // examples where the filterString is set on the filter (opposite logic from above)
    updateFilterStringLangEnGB: function () {
      var filterString = 'state=one|lang=en_GB';
      this._updateFilterString(filterString);
    },

    updateFilterStringLangSvSE: function () {
      var filterString = 'state=one|lang=sv_SE';
      this._updateFilterString(filterString);
    },

    updateFilterStringUrl: function () {
      var filterString = 'state=one|lang=sv_SE|url=http://www.google.com';
      this._updateFilterString(filterString);
    },

    _updateFilterString: function (filterString) {
      var
        filter = {
          filterString: filterString,
          options: {
            forceFilterStringMatching: this.forceFilterStringMatching
          }
        },
        msg = 'filterString on the filter passed to the refresh method set to: <b>' + filterString + '</b>';
      Vigor.componentManager.refresh(filter);
      exampleHelpers.showMsg(msg);
    },

  });

})(jQuery);
