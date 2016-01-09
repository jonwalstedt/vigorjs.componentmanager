var MenuView,
    Backbone = require('backbone'),
    menuTemplate = require('./templates/menu-template.html');

MenuView = Backbone.View.extend({
  render: function () {
    var templateData = {
      title: 'My example component - a menu',
      items: this.collection.toJSON()
    };

    this.$el.html(menuTemplate(templateData));
  },

  dispose: function () {
    console.log('im disposed');
    this.remove();
  }
});

module.exports = MenuView;
