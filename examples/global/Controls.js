var Vigor = Backbone.Vigor || {};

Vigor.ComponentManagerControls = Backbone.View.extend({
  router: undefined,
  className: 'vigorjs-controls',
  template: _.template($('script.controls-template').html()),

  events: {
    'click .vigorjs-controls__toggle-controls': '_onToggleControlsClick',
    'click .add-component': '_onAddComponentBtnClick',
    'click .remove-component': '_onRemoveComponentBtnClick',
    'click .change-component--order': '_onChangeComponentOrderBtnClick',
    'click .change-component--target': '_onChangeComponentTargetBtnClick'
  },

  initialize: function () {
    this.render();
    console.log(Vigor.componentManager.activeComponents);
  },

  render: function () {
    this.$el.html(this.template());
    return this;
  },

  _onToggleControlsClick: function () {
    this.$el.toggleClass('vigorjs-controls--active');
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
