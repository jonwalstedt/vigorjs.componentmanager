var app = app || {};
app.components = app.components || {};

app.components.ProfileOverViewComponent = Backbone.View.extend({

  className: 'profile-overview',
  template: _.template($('script.profile-overview-template').html()),

  initialize: function (arguments) {
    this.title = arguments.title;
    this.text = arguments.text;
    console.log('im the profile-overview-template');
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }

});

