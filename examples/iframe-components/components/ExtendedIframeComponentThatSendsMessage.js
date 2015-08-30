var app = app || {};
app.components = app.components || {};

app.components.ExtendedIframeComponentThatSendsMessage = Vigor.IframeComponent.extend({

  initialize: function (args) {
    console.log('ExtendedIframeComponentThatSendsMessage initialized', args);
  },

  receiveMessage: function (message) {
    this.postMessageToIframe(message);
    this.$el.width(message.width);
    this.$el.height(message.height);
  }

});
