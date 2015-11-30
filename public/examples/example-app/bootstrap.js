define(function (require) {

  'use strict';

  var Vigor = require('vigor'),
      ProducerManager = Vigor.ProducerManager,
      ArticlesProducer = require('producers/ArticlesProducer'),
      FilterProducer = require('producers/FilterProducer'),
      ExampleProject = require('app/app');

  // Setup prodcers
  ProducerManager.registerProducers([
    ArticlesProducer,
    FilterProducer
  ]);

  new ExampleProject({
    el: '.example-app'
  });
});