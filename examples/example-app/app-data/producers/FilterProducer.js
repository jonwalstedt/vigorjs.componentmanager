define(function (require) {

  'use strict';

  var FilterProducer,
      Producer = require('vigor').Producer,
      SubscriptionKeys = require('SubscriptionKeys'),
      ArticlesRepository = require('repositories/articles/ArticlesRepository'),
      FilterRepository = require('repositories/filters/FilterRepository'),
      SectionsRepository = require('repositories/sections/SectionsRepository');


  FilterProducer = Producer.extend({

    PRODUCTION_KEY: SubscriptionKeys.FILTER,
    repositories: [
      SectionsRepository,
      FilterRepository
    ],

    sectionsFetchSubscription: undefined,
    articlesFetchSubscription: undefined,

    subscribeToRepositories: function () {
      Producer.prototype.subscribeToRepositories.call(this);

      this.sectionsFetchSubscription = {
        pollingInterval: 1000 * 60 * 5
      };

      SectionsRepository.addSubscription(SectionsRepository.ALL, this.sectionsFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Producer.prototype.unsubscribeFromRepositories.call(this);
      SectionsRepository.removeSubscription(SectionsRepository.ALL, this.sectionsFetchSubscription);
      ArticlesRepository.removeSubscription(ArticlesRepository.NEWS_WIRE, this.articlesFetchSubscription);
    },

    currentData: function () {
      var filters,
          sections = this.modelsToJSON(SectionsRepository.models),
          time = FilterRepository.getTimeFilterValue(),
          activeFilters = [];

      sections.forEach(function (section) {
        var selected = FilterRepository.get(section.id);
        if (selected) {
          activeFilters.push(selected);
          section.selected = true;
        }
      });

      filters = {
        activeFilters: activeFilters,
        sections: sections,
        time: time
      };

      return filters;
    },

    _updateArticleSubscription: function (diff) {
      var sections = FilterRepository.getSectionsValueArray().join(';'),
          time = FilterRepository.getTimeFilterValue();

      ArticlesRepository.removeSubscription(ArticlesRepository.NEWS_WIRE, this.articlesFetchSubscription);

      this.articlesFetchSubscription = {
        pollingInterval: 1000 * 60 * 30,
        params: {
          section: sections,
          timePeriod: time * 24
        }
      };

      ArticlesRepository.addSubscription(ArticlesRepository.NEWS_WIRE, this.articlesFetchSubscription);
    },

    onDiffInRepository: function () {
      this._updateArticleSubscription();
      Producer.prototype.onDiffInRepository.call(this, arguments);
    }

  });

  return FilterProducer;

});
