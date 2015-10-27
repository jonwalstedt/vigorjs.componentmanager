var app = app || {};
app.services = app.services || {};

(function ($) {
  'use strict';

  var ProjectsService = Vigor.APIService.extend({

    // NAME: 'ProjectsService',
    PROJECTS_RECEIVED: 'projects-received',

    parse: function (response) {
      var models = response.projects;
      Vigor.APIService.prototype.parse.call(this, response);
      this.propagateResponse(this.PROJECTS_RECEIVED, models);
    },

    url: function () {
      return './app-data/services/projects.json';
    }
  });

  app.services.ProjectsService = new ProjectsService();

})(jQuery);
