define(function (require) {

  'use strict';

  var Filter,
      ComponentBase = require('components/ComponentBase'),
      FilterView = require('./FilterView'),
      FilterViewModel = require('./FilterViewModel');

  Filter = ComponentBase.extend({

    _filterViewModel: undefined,
    _filterView: undefined,

    constructor: function (options) {
      this._filterViewModel = new FilterViewModel({subscriptionKey: options.subscriptionKey});
      this._filterView = new FilterView({viewModel: this._filterViewModel});

      this.$el = this._filterView.$el;

      $.when(this._filterView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._filterView.render();
      return this;
    },

    dispose: function () {
      console.log('SectionFilter disposed');
      this._filterView.dispose();
      this._filterViewModel.dispose();
      this._filterView = undefined;
      this._filterViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }

  });

  return Filter;

});
