define(function (require) {

  'use strict';

  var FileList,
      ComponentBase = require('components/ComponentBase'),
      FileListView = require('./FileListView'),
      FileListViewModel = require('./FileListViewModel');

  FileList = ComponentBase.extend({

    $el: undefined,
    _fileListViewModel: undefined,
    _fileListView: undefined,

    constructor: function (options) {
      console.log('FileList initialized');
      this._fileListViewModel = new FileListViewModel({subscriptionKey: options.subscriptionKey});
      options.viewModel = this._fileListViewModel;

      this._fileListView = new FileListView(options);
      this.$el = this._fileListView.$el;
      $.when(this._fileListView.getRenderDonePromise()).then(_.bind(this._resolvePromise, this));
      ComponentBase.prototype.constructor.apply(this, arguments);
    },

    render: function () {
      this._fileListView.render();
      return this;
    },

    dispose: function () {
      console.log('Filelist disposed');
      this._fileListView.dispose();
      this._fileListViewModel.dispose();
      this._fileListView = undefined;
      this._fileListViewModel = undefined;
      this.$el.remove();
      this.$el = undefined;
    },

    _resolvePromise: function () {
      this._renderDeferred.resolve();
    }
  });

  return FileList;

});
