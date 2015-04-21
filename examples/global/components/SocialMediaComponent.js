var app = app || {};
app.components = app.components || {};

app.components.SocialMediaComponent = Backbone.View.extend({

  className: 'social-media',
  template: _.template($('script.social-media-template').html()),

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  }
});

