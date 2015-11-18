define(function (require) {

  'use strict';

  var Vigor = require('vigor'),
      ProducerManager = Vigor.ProducerManager,
      ProjectsProducer = require('producers/ProjectsProducer'),
      ExampleProject = require('app/app');

  // require('./app-data/EventKeys');
  // require('./app-data/SubscriptionKeys');

  // Setup prodcers
  ProducerManager.registerProducers([
    ProjectsProducer
  ]);

  new ExampleProject({
    el: '.example-app'
  });
});