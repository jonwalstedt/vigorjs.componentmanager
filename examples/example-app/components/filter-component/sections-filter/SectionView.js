define(function (require) {

  'use strict';

  var SectionView,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      sectionTemplate = require('hbars!./templates/section-filter-template');

  SectionView = Backbone.View.extend({

    className: 'sections-filter__list-item',
    tagName: 'li',

    events: {
      'change .sections-filter__section': '_onFilterChange'
    },

    initialize: function (options) {
      this.listenTo(this.model, 'change:selected', this.render);
      this.listenTo(this.model, 'remove', this.dispose);
    },

    render: function () {
      var templateData = this.model.toJSON();
      this.$el.html(sectionTemplate(templateData));
      this.$el.toggleClass('sections-filter__list-item--selected', templateData.selected);
      return this;
    },

    dispose: function () {
      this.remove();
    },

    _onFilterChange: function (event) {
      var isChecked = $(event.currentTarget).is(':checked');
      this.model.set('selected', isChecked);
    }

  });

  return SectionView;

});