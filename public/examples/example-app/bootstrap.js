define(function (require) {

  'use strict';

  var Vigor = require('vigor'),
      ProducerManager = Vigor.ProducerManager,
      UserProfileProducer = require('producers/UserProfileProducer'),
      MusicQuotaProducer = require('producers/MusicQuotaProducer'),
      ExampleProject = require('app/app');

  // Validate producer/component contracts
  // Vigor.setup({validateContract: true});

  // Setup prodcers
  ProducerManager.registerProducers([
    UserProfileProducer,
    MusicQuotaProducer
  ]);

  new ExampleProject({
    el: '.example-app'
  });
});