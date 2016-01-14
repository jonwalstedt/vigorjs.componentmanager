define(function (require) {

  'use strict';

  var Vigor = require('vigor'),
      ProducerManager = Vigor.ProducerManager,
      UserProfileProducer = require('producers/UserProfileProducer'),
      // ArticlesProducer = require('producers/ArticlesProducer'),
      // FilterProducer = require('producers/FilterProducer'),
      ExampleProject = require('app/app');

  // Setup prodcers
  ProducerManager.registerProducers([
    UserProfileProducer
    // ArticlesProducer,
    // FilterProducer
  ]);

  new ExampleProject({
    el: '.example-app'
  });
});