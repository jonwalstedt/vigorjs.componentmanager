var app = app || {};
app.components = app.components || {};

app.components.FilterComponent = Backbone.View.extend({

  _renderDeferred: undefined,
  className: 'list-component',
  order: undefined,

  initialize: function (args) {
    console.log('component initialized', args);
    this.order = args.order;
    this.url = args.url;
    this.$el.css("background", args.background);
    this._renderDeferred = $.Deferred();
  },

  render: function () {
    setTimeout(_.bind(function () {
      markup = '<a href="' + this.url + '">Instance with order: ' + this.order + '</a>';
      this.$el.html(markup);

      this._renderDeferred.resolve();
      console.log('promise resolved');
    }, this), Math.random()*1000);

    return this;
  },

  dispose: function () {
    console.log('component disposed');
    this.remove();
  },

  getRenderDonePromise: function () {
    return this._renderDeferred.promise();
  }

});
