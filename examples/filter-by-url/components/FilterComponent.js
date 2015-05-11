var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  title: undefined,
  args: undefined,

  initialize: function (args) {
    this.title = args.title;
    this.urlPattern = args.urlPattern;
    this.args = args;
    this.urlParamsModel = args.urlParamsModel
    this.listenTo(this.urlParamsModel, 'change', _.bind(this._onUrlParamsChange, this));
  },

  render: function () {
    markup = '<h2>Filter component ' + this.title + '</h2>';
    markup += '<p>urlPattern: <em>' + this.urlPattern + '</em></p>';
    markup += '<p>arguments: <pre>' + this._stringify(this.args) + '</pre></p>';
    markup += '<p>urlParamsModel.toJSON():<pre> ' + this._stringify(this.urlParamsModel.toJSON()) + '</pre></p>';
    markup += '<p class="params-output"></p>';
    this.$el.html(markup);
    return this;
  },

  dispose: function () {
    this.remove();
  },

  _stringify: function (string) {
    return JSON.stringify(string, null, 2);
  },

  _onUrlParamsChange: function () {
    var $output = $(".params-output", this.el),
    message = 'This component doesnt reinstantiate when the url changes but instead gets new params passed through the urlParamsModel: ';
    $output.html(message + '<pre>' + this._stringify(this.urlParamsModel.toJSON())) + '</pre>';

  }
});
