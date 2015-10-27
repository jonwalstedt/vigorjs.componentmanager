var app = app || {};
app.repositories = app.repositories || {};

(function ($) {
  'use strict';

  var
  ProjectsService = app.services.ProjectsService,
  ProjectsRepository = Vigor.ServiceRepository.extend({

    ALL: 'all',
    BY_ID: 'id',
    services: {
      'all': ProjectsService,
      'id': ProjectsService
    },

    initialize: function () {
      ProjectsService.on(ProjectsService.PROJECTS_RECEIVED, _.bind(this._onProjectsReceived, this));
      Vigor.ServiceRepository.prototype.initialize.call(this, arguments);
    },

    _onProjectsReceived: function (models) {
      this.set(models);
    }
  });

  app.repositories.ProjectsRepository = new ProjectsRepository();

})(jQuery);
