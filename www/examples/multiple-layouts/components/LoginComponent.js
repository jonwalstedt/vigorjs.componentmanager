var app = app || {};
app.components = app.components || {};

app.components.LoginComponent = Backbone.View.extend({

  className: 'example-login',
  template: _.template($('script.login-template').html()),
  events: {
    'click .login__button': '_onLoginClick',
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  dispose: function () {
    this.remove();
  },

  _onLoginClick: function () {
    console.log('do some login magic and then redirect to home')
    window.localStorage.setItem('isAuthenticated', true);
    Backbone.history.navigate('home', {trigger: true});
  }
});

