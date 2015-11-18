define(function (require) {

  'use strict';

  var ProjectsService,
      APIService = require('vigor').APIService;

  ProjectsService = APIService.extend({

    // NAME: 'ProjectsService',
    PROJECTS_RECEIVED: 'projects-received',

    parse: function (response) {
      var models = response.projects;
      APIService.prototype.parse.call(this, response);
      this.propagateResponse(this.PROJECTS_RECEIVED, models);
    },

    url: function () {
      return './app-data/services/projects.json';
    }
  });

  return new ProjectsService();
});
