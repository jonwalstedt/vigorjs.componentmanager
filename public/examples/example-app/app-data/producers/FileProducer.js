define(function (require) {

  'use strict';

  var FileProducer,
      Vigor = require('vigor'),
      FilesRepository = require('repositories/files/FilesRepository'),
      MathUtil = require('utils/MathUtil'),
      subscriptionKeys = require('SubscriptionKeys');

  FileProducer = Vigor.IdProducer.extend({

    PRODUCTION_KEY: subscriptionKeys.FILE,
    repositories: [FilesRepository],

    subscribeToRepositories: function () {
      Vigor.IdProducer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      FilesRepository.addSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Vigor.IdProducer.prototype.unsubscribeFromRepositories.call(this);
      FilesRepository.removeSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function (id) {
      var file = FilesRepository.get(id) ? FilesRepository.get(id).toJSON() : {},
          fileType = file ? file.fileType : 'all',
          files = fileType ? FilesRepository.getFilesByFileType(fileType) : FilesRepository.models,
          index,
          prevFileId,
          nextFileId;

      files = _.sortBy(this.modelsToJSON(files), 'uploaded');
      index = _.findIndex(files, function (f) {
        return f.id === file.id;
      });

      file.prevFileId = files[index - 1] ? files[index - 1].id : undefined;
      file.nextFileId = files[index + 1] ? files[index + 1].id : undefined;
      file.fileSizeReadable = MathUtil.formatBytes(file.fileSize, 2).string;

      return file;
    },

  });

  return FileProducer;

});
