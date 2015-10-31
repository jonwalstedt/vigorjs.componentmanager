var app = app || {};

(function ($) {
  'use strict';

  app.Filter = Backbone.View.extend({

    events: {
      'click .restore': 'restore',
      'click .include-if-string-matches': 'includeIfStringMatches',
      'click .exclude-if-string-matches': 'excludeIfStringMatches',
      'click .has-to-match-string': 'hasToMatchString',
      'click .cant-match-string': 'cantMatchString',
      'click .toggle-forced-filter-string-matching': 'toggleForcedFilterStringMatching',
      'click .update-filter-string-lang-en-gb': 'updateFilterStringLangEnGB',
      'click .update-filter-string-lang-sv-se': 'updateFilterStringLangSvSE',
      'click .update-filter-string-url': 'updateFilterStringUrl'
    },

    initialize: function () {
      Vigor.componentManager.initialize({
        componentSettings: window.componentSettings,
        context: this.$el
      });

      this.restore();
    },

    restore: function () {
      Vigor.componentManager.refresh();
      showMsg('Click links above to see examples of filtering using a filterString', {});
    },

    // examples where the filterString is set on the instanceDefinition
    includeIfStringMatches: function () {
      var
        filter = {
          includeIfStringMatches: 'first'
        },
        msg = 'includeIfStringMatches - will show instanceDefinitions that has a filterString that matches <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined (unless forceFilterStringMatching is set to true)';
      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
    },

    excludeIfStringMatches: function () {
      var
        filter = {
          excludeIfStringMatches: 'first'
        },
        msg = 'excludeIfStringMatches - will show instanceDefinitions that has a filterString that does <b>not</b> match <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined (unless forceFilterStringMatching is set to true)';

      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
    },

    hasToMatchString: function () {
      var
        filter = {
          hasToMatchString: 'first'
        },
        msg = 'hasToMatchString - will filter instanceDefinitions to only show instances that has a filterString that matches <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';

      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
    },

    cantMatchString: function () {
      var
        filter = {
          cantMatchString: 'first'
        },
        msg = 'cantMatchString - will filter instanceDefinitions to only show instances that has a filterString that does <b>not</b> match <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';
      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
    },

    toggleForcedFilterStringMatching: function () {
      var filter = Vigor.componentManager.getActiveFilter(),
          msg = 'toggleForcedFilterStringMatching has been toggled';
      filter.options.forceFilterStringMatching = !filter.options.forceFilterStringMatching;
      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
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
      var filterString = 'state=one|lang=sv_SE|http://www.google.com';
      this._updateFilterString(filterString);
    },

    _updateFilterString: function (filterString) {
      var
        filter = {
          filterString: filterString
        },
        msg = 'filterString on the filter passed to the refresh method set to: <b>' + filterString + '</b>';
      Vigor.componentManager.refresh(filter);
      showMsg(msg, filter);
    },

  });

})(jQuery);
