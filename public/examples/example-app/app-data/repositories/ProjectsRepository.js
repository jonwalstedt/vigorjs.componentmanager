define(function (require) {

  'use strict';

  var ProjectsRepository,
      ServiceRepository = require('vigor').ServiceRepository,
      ProjectsService = require('services/ProjectsService');

  ProjectsRepository = ServiceRepository.extend({

    ALL: 'all',
    BY_ID: 'id',
    services: {
      'all': ProjectsService,
      'id': ProjectsService
    },

    initialize: function () {
      ProjectsService.on(ProjectsService.PROJECTS_RECEIVED, _.bind(this._onProjectsReceived, this));
      ServiceRepository.prototype.initialize.call(this, arguments);
    },

    _onProjectsReceived: function (models) {
      this.set(models);
    }
  });

  return new ProjectsRepository();

});
