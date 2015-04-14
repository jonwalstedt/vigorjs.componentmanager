var app = app || {};
app.components = app.components || {};

app.components.ComponentOne = Backbone.View.extend({

  title: undefined,
  text: undefined,

  initialize: function (arguments) {
    this.title = arguments.title;
    this.text = arguments.text;
    console.log('im the global component', arguments);
  },

  render: function () {
    this.$el.html('Component One' + this._getMarkup());
    return this;
  },

  dispose: function () {
    this.remove();
  },

  _getMarkup: function () {
    var markup = '<h1>' + this.title + '</h1>';
    markup += '<p>' + this.text + '</p>';
    return markup;
  }
});

