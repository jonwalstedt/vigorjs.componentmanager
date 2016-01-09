define(function (require) {

  'use strict';

  var FilterView,
      // $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      ComponentViewBase = require('components/ComponentViewBase'),
      SectionFilterView = require('./sections-filter/SectionsFilterView'),
      TimeFilterView = require('./time-filter/TimeFilterView');

  FilterView = ComponentViewBase.extend({

    className: 'filter-component',
    sectionFilterView: undefined,
    timeFilterView: undefined,

    initialize: function (options) {
      var renderDonePromises;
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.sectionFilterView = new SectionFilterView({collection: this.viewModel.sectionsCollection});
      this.timeFilterView = new TimeFilterView({model: this.viewModel.timeModel});

      this.listenTo(this.viewModel.sectionsCollection, 'change:selected', this.updateFilter);
      this.listenTo(this.viewModel.timeModel, 'change:selectedTime', this.updateFilter);

      renderDonePromises = [this.sectionFilterView.getRenderDonePromise(), this.timeFilterView.getRenderDonePromise()];
      $.when.apply($, renderDonePromises).then(_.bind(this.resolvePromise, this));
    },

    renderStaticContent: function () {
      this.$el.append(this.timeFilterView.render().$el);
      this.$el.append(this.sectionFilterView.render().$el);
    },

    renderDynamicContent: function () {},

    resolvePromise: function () {
      this._renderDeferred.resolve();
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      this.sectionFilterView.dispose();
      this.timeFilterView.dispose();
      ComponentViewBase.prototype.dispose.call(this, arguments);
    },

    updateFilter: function () {
      var filter, sections, time;

      sections = _.map(this.viewModel.getSelectedSections(), function (sectionModel) {
        return sectionModel.get('section');
      }).join(';');

      time = this.viewModel.getSelectedTime();

      filter = this._getPath() + '?sections=' + sections + '&time=' + time;
      Backbone.history.navigate(filter, true);
    },

    _getPath: function () {
      var path = Backbone.history.fragment,
          endIndex = path.indexOf('?');

      if (endIndex < 0)
        endIndex = path.length;

      path = path.substring(0, endIndex);
      return path;
    }
  });

  return FilterView;

});