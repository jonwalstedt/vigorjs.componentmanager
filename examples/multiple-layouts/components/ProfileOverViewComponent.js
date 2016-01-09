var app = app || {};
app.components = app.components || {};

app.components.ProfileOverViewComponent = Backbone.View.extend({

  className: 'example-profile-overview',
  template: _.template($('script.profile-overview-template').html()),

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }

});

