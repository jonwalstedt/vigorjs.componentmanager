define(function (require) {

  'use strict';

  var ArticlesProducer,
      Producer = require('vigor').Producer,
      SubscriptionKeys = require('SubscriptionKeys'),
      FilterRepository = require('repositories/filters/FilterRepository'),
      SectionsRepository = require('repositories/sections/SectionsRepository'),
      ArticlesRepository = require('repositories/articles/ArticlesRepository');


  ArticlesProducer = Producer.extend({

    PRODUCTION_KEY: SubscriptionKeys.ARTICLES,
    repositories: [ArticlesRepository],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      var sections = FilterRepository.getSectionsValueArray().join(';');

      if (sections === '') {
        sections = 'all';
      }

      Producer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 1000 * 60 * 30,
        params: {
          section: sections,
          timePeriod: 20,
        }
      };

      ArticlesRepository.addSubscription(ArticlesRepository.NEWS_WIRE, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Producer.prototype.unsubscribeFromRepositories.call(this);
      ArticlesRepository.removeSubscription(ArticlesRepository.NEWS_WIRE, this.repoFetchSubscription);
    },

    currentData: function () {
      var filters = FilterRepository.getSectionsValueArray(),
          sectionLabels = SectionsRepository.getSectionLabelsByIds(filters),
          articles = this.modelsToJSON(ArticlesRepository.getArticlesBySections(sectionLabels));

      articles = _.map(articles, function (model) {
        var updated = new Date(model.updated_date),
            updatedStr = updated.toUTCString();

        updatedStr = updatedStr.substr(0, updatedStr.length - 12);
        updatedStr += updated.toTimeString().split(' ')[0].substr(0, 5)

        return {
          title: model.title,
          abstract: model.abstract,
          section: model.section,
          thumbnail: model.thumbnail_standard,
          updated: updatedStr
        }
      });

      return articles;
    }

  });

  return ArticlesProducer;

});
