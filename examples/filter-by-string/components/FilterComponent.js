var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  title: undefined,
  initialize: function (args) {
    this.title = args.title;
    this.filterString = args.filterString;
  },

  render: function () {
    markup = '<p>Filter component ' + this.title + '<br/>';
    markup += '<em>filterString: ' + this.filterString+ '</em></p>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    this.remove();
  }
});
