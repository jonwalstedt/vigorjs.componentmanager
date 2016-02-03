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

    comparator: 'uploaded',

    initialize: function () {
      FileService.on(FileService.FILES_RECEIVED, _.bind(this._onFilesReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
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

    getBytesUsedByVideos: function () {
      return this.getBytesUsedByFileType('video');
    },

    getBytesUsedByPhotos: function () {
      return this.getBytesUsedByFileType('photo');
    },

    getFIlesUploadedTheLastNthMonths: function (nrOfMonths) {
      var cutOffPoint = new Date();
      cutOffPoint.setMonth(cutOffPoint.getMonth() - nrOfMonths);
      return _.filter(this.models, function (model) {
        return model.get('uploaded') > cutOffPoint;
      });
    },

    getCount: function () {
      return this.models.length;
    },

    getFilesByFileType: function (fileType) {
      return this.where({fileType: fileType});
    },

    getCountByFileType: function (fileType) {
      return this.getFilesByFileType(fileType).length;
    },

    _onFilesReceived: function (files) {
      this.set(files);
    }
  });

  return new FilesRepository();

});
