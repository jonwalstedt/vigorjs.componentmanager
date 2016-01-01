ExampleComponent = Backbone.View.extend({
  className: 'example-component',
  template: _.template($('.example-component-template').html()),

  // only used to display incomming properties
  defaultInstanceDefinitionObj: {
    id: undefined,
    componentId: undefined,
    args: undefined,
    order: undefined,
    targetName: undefined,
    reInstantiate: false,

    filterString: undefined,
    includeIfFilterStringMatches: undefined,
    excludeIfFilterStringMatches: undefined,
    conditions: undefined,
    maxShowCount: undefined,
    urlPattern: undefined
  },

  events: {
    'click .example-component__toggle-fullsize': '_toggleFullsize'
  },

  initialize: function (args) {
    var
      id = args.title || args.id,
      templateData,
      instanceDefinition = _.extend({},
        this.defaultInstanceDefinitionObj,
        _.omit(args, 'urlParams', 'urlParamsCollection', 'title', 'background')
      );

    instanceDefinition.args = args;
    this.templateData = {
      id: id,
      instanceDefinition: exampleHelpers.stringify(instanceDefinition),
      arguments: exampleHelpers.stringify(arguments),
    };

    console.log('ExampleComponent with id ' + id + ' has been instantiated');
    this.arguments = arguments;
    this.id = id;
    this.$el.css("background", args.background);
    this.urlParamsCollection = args.urlParamsCollection;
    this.listenTo(this.urlParamsCollection.at(0), 'change:url', _.bind(this._onUrlParamsChange, this));
  },

  render: function () {
    this.$el.html(this.template(this.templateData));
    this.$output = $(".component-output", this.$el);
    return this;
  },

  dispose: function () {
    console.log('ExampleComponent with id: ' + this.id + ' has been disposed');
    this.remove();
  },

  _onUrlParamsChange: function () {
    console.log('_onUrlParamsChange', this.id);
    message = 'This component doesnt reinstantiate when the url changes but instead gets new params passed through the urlParamsCollection: ';
    this.$output.html(message + '<pre>' + exampleHelpers.stringify(this.urlParamsCollection.toJSON())) + '</pre>';
    this.$el.flash(400, 1);
  },

  _toggleFullsize: function (event) {
    $btn = $(event.currentTarget);
    $parent = $btn.parent();
    $btn.toggleClass('entypo-resize-full');
    $btn.toggleClass('entypo-resize-small');
    $parent.toggleClass('example-component--fullsize');
  }
});
