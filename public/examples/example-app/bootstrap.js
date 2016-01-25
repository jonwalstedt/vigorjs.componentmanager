define(function (require) {

  'use strict';

  var Vigor = require('vigor'),
      ProducerManager = Vigor.ProducerManager,
      UserProfileProducer = require('producers/UserProfileProducer'),
      MusicQuotaProducer = require('producers/MusicQuotaProducer'),
      VideoQuotaProducer = require('producers/VideoQuotaProducer'),
      PhotoQuotaProducer = require('producers/PhotoQuotaProducer'),
      DailyUsageProducer = require('producers/DailyUsageProducer'),
      ExampleProject = require('app/app');

  // Validate producer/component contracts
  // Vigor.setup({validateContract: true});

  // Setup prodcers
  ProducerManager.registerProducers([
    UserProfileProducer,
    MusicQuotaProducer,
    PhotoQuotaProducer,
    VideoQuotaProducer,
    DailyUsageProducer
  ]);

  new ExampleProject({
    el: '.example-app'
  });
});