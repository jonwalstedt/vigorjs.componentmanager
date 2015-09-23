var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  title: undefined,
  initialize: function (args) {
    this.title = args.title;
    this.filterString = args.filterString;
    this.includeIfFilterStringMatches = args.includeIfFilterStringMatches || "includeIfFilterStringMatches = undefined",
    this.excludeIfFilterStringMatches = args.excludeIfFilterStringMatches || "excludeIfFilterStringMatches = undefined",
    this.hasToMatchFilterString = args.hasToMatchFilterString || "hasToMatchFilterString = undefined",
    this.cantMatchFilterString = args.cantMatchFilterString || 'cantMatchFilterString = undefined'
  },

  render: function () {
    markup = '<h4>Filter component ' + this.title + '</h4>';
    markup += '<p>filterString: ' + this.filterString + '</p>';
    markup += '<p>' + this.includeIfFilterStringMatches + '</p>';
    markup += '<p>' + this.excludeIfFilterStringMatches + '</p>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    this.remove();
  }
});
