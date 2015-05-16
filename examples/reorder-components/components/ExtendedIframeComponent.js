var app = app || {};
app.components = app.components || {};

app.components.ExtendedIframeComponent = Vigor.IframeComponent.extend({

  initialize: function (args) {
    console.log('IframeComponentBaseExtended initialized', args);
  },

   dispose: function () {
    console.log('component disposed');
    this.remove();
  },

});
