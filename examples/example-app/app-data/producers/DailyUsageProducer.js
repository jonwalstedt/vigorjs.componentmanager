define(function (require) {

  'use strict';

  var DailyUsageProducer,
      MathUtil = require('utils/MathUtil'),
      AccountTypes = require('app/AccountTypes'),
      ProducerBase = require('./ProducerBase'),
      FilesRepository = require('repositories/files/FilesRepository'),
      subscriptionKeys = require('SubscriptionKeys');

  DailyUsageProducer = ProducerBase.extend({

    PRODUCTION_KEY: subscriptionKeys.DAILY_USAGE,
    repositories: [FilesRepository],

    repoFetchSubscription: undefined,

    monthNames: [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ],

    subscribeToRepositories: function () {
      ProducerBase.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 10,
        params: {}
      };

      FilesRepository.addSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      ProducerBase.prototype.unsubscribeFromRepositories.call(this);
      FilesRepository.removeSubscription(FilesRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function () {
      var filesUploadedTheLastSixMonths = FilesRepository.getFIlesUploadedTheLastNthMonths(6),
          fileTypes = _.uniq(FilesRepository.pluck('fileType')),
          datasets = [],
          months,
          files;

      fileTypes.unshift('total');

      files = _.map(filesUploadedTheLastSixMonths, function (file) {
        var file = file.toJSON();
        file.month = new Date(file.uploaded).getMonth();
        file.monthName = this.monthNames[file.month];
        return file;
      }, this);

      months = this._getUniqeMonthsFromFiles(filesUploadedTheLastSixMonths);

      for (var i = 0; i < fileTypes.length; i++) {
        datasets.push(this._getMBPerMonthDataSet(fileTypes[i], files, months));
      };

      return {
        labels: months,
        datasets: datasets
      };
    },

    _getUniqeMonthsFromFiles: function (files) {
      return _.uniq(_.map(files, function (file) {
        return this.monthNames[new Date(file.get('uploaded')).getMonth()];
      }, this));
    },

    _getMBPerMonthDataSet: function (fileType, files, months) {
      return {
        label: fileType.charAt(0).toUpperCase() + fileType.slice(1),
        data: _.map(months, function (month) {
          var fls, bytes, bytesUsed;
          if (fileType == 'total')
            fls = _.where(files, {monthName: month});
          else
            fls = _.where(files, {monthName: month, fileType: fileType});

          bytes = _.pluck(fls, 'fileSize'),
          bytesUsed = _.reduce(bytes, function (memo, byte) { return memo + byte; }, 0);

          // MB uploaded per month
          return (bytesUsed/1024/1024).toFixed(1);

          // Nr of files uploaded per month
          // return _.where(files, {monthName: month, fileType: 'music'}).length;
        })
      };
    }

  });

  return DailyUsageProducer;

});
