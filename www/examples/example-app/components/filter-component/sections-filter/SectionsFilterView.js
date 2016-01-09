define(function (require) {

  'use strict';

  var SectionsFilterView,
      SectionView = require('./SectionView'),
      Backbone = require('backbone');

  SectionsFilterView = Backbone.View.extend({

    className: 'sections-filter',
    tagName: 'ul',
    _renderDeferred: undefined,

    initialize: function () {
      Backbone.View.prototype.initialize.apply(this, arguments);
      this.listenTo(this.collection, 'add', this._onSectionAdded);
      this._renderDeferred = $.Deferred();
      this.throttledResolvePromise = _.throttle(this._resolvePromise, 20, {leading: false});
    },

    render: function () {
      return this;
    },

    getRenderDonePromise: function () {
      return this._renderDeferred.promise();
    },

    dispose: function () {
      this.remove();
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    },

    _onSectionAdded: function (sectionModel) {
      var section = new SectionView({model: sectionModel});
      this.$el.append(section.render().$el);
      this.throttledResolvePromise();
    }

  });

  return SectionsFilterView;

});