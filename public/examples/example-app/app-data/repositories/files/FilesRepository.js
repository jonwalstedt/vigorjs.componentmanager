define(function (require) {

  'use strict';

  var FilesRepository,
      FileModel = require('./FileModel'),
      ServiceRepository = require('vigor').ServiceRepository,
      FileService = require('services/FileService');

  FilesRepository = ServiceRepository.extend({

    ALL: 'all',
    services: {
      'all': FileService,
    },

    model: FileModel,

    initialize: function () {
      FileService.on(FileService.FILES_RECEIVED, _.bind(this._onFilesReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
      setInterval(_.bind(function(){
        this.trigger('change', this.models[0]);
      },this), 15000)
    },

    getBytesUsedByFileType: function (fileType) {
      var files = this.where({fileType: fileType});
      return _.reduce(files, function (memo, model) {
        return memo + model.get('fileSize');
      }, 0);
    },

    getBytesUsedByMusic: function () {
      return this.getBytesUsedByFileType('music');
    },

    _onFilesReceived: function (files) {
      this.set(files);
    }
  });

  return new FilesRepository();

});
