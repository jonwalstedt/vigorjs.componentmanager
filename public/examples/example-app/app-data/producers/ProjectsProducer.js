var app = app || {};
app.producers = app.producers || {};

(function ($) {
  'use strict';

  var SubscriptionKeys = Vigor.SubscriptionKeys,
      ProjectsRepository = app.repositories.ProjectsRepository;

  app.producers.ProjectsProducer = Vigor.Producer.extend({

    PRODUCTION_KEY: SubscriptionKeys.PROJECTS,
    repositories: [ProjectsRepository],

    repoFetchSubscription: undefined,

    subscribeToRepositories: function () {
      Vigor.Producer.prototype.subscribeToRepositories.call(this);

      this.repoFetchSubscription = {
        pollingInterval: 10000
      };

      ProjectsRepository.addSubscription(ProjectsRepository.ALL, this.repoFetchSubscription);
    },

    unsubscribeFromRepositories: function () {
      Vigor.Producer.prototype.unsubscribeFromRepositories.call(this);
      ProjectsRepository.removeSubscription(ProjectsRepository.ALL, this.repoFetchSubscription);
    },

    currentData: function () {
      var models = this.modelsToJSON(ProjectsRepository.models),
          len = models.length,
          i = 0;

      for (var i = 0; i < len; i++) {
        if (i % 2 == 0 && i != 0) {
          models.splice(i, 0, {type: 'banner'});
        }
      };

      return models;
    }

  });

})(jQuery);
