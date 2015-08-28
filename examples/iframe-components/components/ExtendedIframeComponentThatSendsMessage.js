var app = app || {};
app.components = app.components || {};

app.components.ExtendedIframeComponentThatSendsMessage = Vigor.IframeComponent.extend({

  initialize: function (args) {
    console.log('ExtendedIframeComponentThatSendsMessage initialized', args);
  },

   dispose: function () {
    console.log('component disposed');
    this.remove();
  },

});
