var app = app || {};

(function ($) {
  'use strict';

  app.Router = Backbone.Router.extend({

    $activeFilter: undefined,
    $msgWrapper: undefined,

    routes: {
      "": "home",
      "include-if-string-matches": "includeIfStringMatches",
      "exclude-if-string-matches": "excludeIfStringMatches",
      "has-to-match-string": "hasToMatchString",
      "cant-match-string": "cantMatchString",
      "update-filter-string-lang-en-gb": "updateFilterStringLangEnGB",
      "update-filter-string-lang-sv-se": "updateFilterStringLangSvSE",
      "update-filter-string-url": "updateFilterStringUrl",
    },

    initialize: function () {
      var filterStr;
      this.$activeFilter= $('.active-filter');
      this.$msgWrapper = $('.msg-wrapper');
      this._filterTemplate = _.template($('.filter-template').html());
    },

    home: function () {
      Vigor.componentManager.refresh();
      this._showMsg('Click links above to see examples of filtering using a filterString', {});
    },

    // examples where the filterString is set on the instanceDefinition
    includeIfStringMatches: function () {
      var
        filter = {
          includeIfStringMatches: 'first'
        },
        msg = 'includeIfStringMatches - will show instanceDefinitions that has a filterString that matches <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined';

      Vigor.componentManager.refresh(filter);
      this._showMsg(msg, filter);
    },

    excludeIfStringMatches: function () {
      var
        filter = {
          excludeIfStringMatches: 'first'
        },
        msg = 'excludeIfStringMatches - will show instanceDefinitions that has a filterString that does <b>not</b> match <b>"first"</b>, including instanceDefinitions that has the filterString property set to undefined';

      Vigor.componentManager.refresh(filter);
      this._showMsg(msg, filter);
    },

    hasToMatchString: function () {
      var
        filter = {
          hasToMatchString: 'first'
        },
        msg = 'hasToMatchString - will filter instanceDefinitions to only show instances that has a filterString that matches <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';

      Vigor.componentManager.refresh(filter);
      this._showMsg(msg, filter);
    },

    cantMatchString: function () {
      var
        filter = {
          cantMatchString: 'first'
        },
        msg = 'cantMatchString - will filter instanceDefinitions to only show instances that has a filterString that does <b>not</b> match <b>"first"</b>, excluding instanceDefinitions that has the filterString set to undefined';
      Vigor.componentManager.refresh(filter);
      this._showMsg(msg, filter);
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
      this._showMsg(msg, filter);
    },

    // Methods below is just used to display the filter on the example page
    _showMsg: function (msg, filter) {
      filter = this._setFilterDefaults(filter);
      this.$activeFilter.html(this._filterTemplate(filter));
      this.$msgWrapper.html(msg);
    },

    _setFilterDefaults: function (filter) {
      filter.url = filter.url || 'undefined';
      filter.filterString = filter.filterString || 'undefined';
      filter.includeIfStringMatches = filter.includeIfStringMatches || 'undefined';
      filter.excludeIfStringMatches = filter.excludeIfStringMatches || 'undefined';
      filter.hasToMatchString = filter.hasToMatchString || 'undefined';
      filter.cantMatchString = filter.cantMatchString || 'undefined';

      for (var key in filter) {
        if (filter[key] !== 'undefined') {
          filter[key] = '<b>' + filter[key] + '</b>';
        }
      }

      return filter;
    }
  });

})(jQuery);
