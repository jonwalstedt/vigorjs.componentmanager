var app = app || {};
app.components = app.components || {};

app.components.BaseComponent = Backbone.View.extend({

  _renderDeferred: undefined,

  initialize: function (args) {
    Backbone.View.prototype.initialize.call(this);
    this._renderDeferred = $.Deferred();
  },

  dispose: function () {
    console.log('component disposed');
    this.remove();
  },

  getRenderDonePromise: function () {
    return this._renderDeferred.promise();
  }
});
