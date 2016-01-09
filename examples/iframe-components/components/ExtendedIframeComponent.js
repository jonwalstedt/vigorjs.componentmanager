var app = app || {};
app.components = app.components || {};

app.components.ExtendedIframeComponent = Vigor.IframeComponent.extend({

  initialize: function (args) {
    console.log('ExtendedIframeComponent initialized', args);
    Vigor.IframeComponent.prototype.initialize.call(this);
  },

   dispose: function () {
    console.log('component disposed');
    this.remove();
  },

});
