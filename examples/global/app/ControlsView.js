var app = app || {};

ControlsView = Backbone.View.extend({
  router: undefined,
  className: 'controls',
  template: _.template($('script.controls-template').html()),

  events: {
    'click .add-component': '_onAddComponentBtnClick',
    'click .remove-component': '_onRemoveComponentBtnClick',
    'click .change-component--order': '_onChangeComponentOrderBtnClick',
    'click .change-component--target': '_onChangeComponentTargetBtnClick'
  },

  initialize: function () {
    this.render();
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  _onAddComponentBtnClick: function () {
    var instanceDefinition = window.componentSettings.targets.main[0],
        instanceDefinitionObj;

    instanceDefinition.id = Date.now();
    instanceDefinitionObj = {
      main: [instanceDefinition]
    };

    Vigor.componentManager.addInstance(instanceDefinitionObj);
  },

  _onRemoveComponentBtnClick: function () {
    var component = Vigor.componentManager.activeComponents.at(0)
    Vigor.componentManager.removeInstance(component.get('id'));
  },

  _onChangeComponentOrderBtnClick: function () {
    var component = Vigor.componentManager.activeComponents.at(0),
    order = component.get('order');
    order++;
    component.set('order', order);
  },

  _onChangeComponentTargetBtnClick: function () {
    var component = Vigor.componentManager.activeComponents.at(0);
    component.set('targetName', 'component-area-sidebar-second');
  }
});
