ExampleComponent = Backbone.View.extend({
  className: 'example-component',
  template: _.template($('.example-component-template').html()),
  events: {
    'click .toggle-fullsize': '_toggleFullsize'
  },

  initialize: function (args) {
    var
      title = args.title || args.id,
      templateData = {
        title: title,
        urlPattern: args.urlPattern || 'undefined',
        filterString: args.filterString || 'undefined',
        includeIfFilterStringMatches: args.includeIfFilterStringMatches || 'undefined',
        excludeIfFilterStringMatches: args.excludeIfFilterStringMatches || 'undefined',
        conditions: args.conditions || 'undefined',
        urlParamsCollection: this._stringify(args.urlParamsCollection.toJSON()),
        args: this._stringify(args)
      };

    console.log('ExampleComponent with id ' + title + ' has been instantiated');
    this.title = title;
    this.templateData = this._highlightTemplateData(templateData);
    this.$el.css("background", args.background);
    this.urlParamsCollection = args.urlParamsCollection;
    this.listenTo(this.urlParamsCollection, 'change', _.bind(this._onUrlParamsChange, this));
  },

  render: function () {
    this.$el.html(this.template(this.templateData));
    this.$output = $(".component-output", this.$el);
    return this;
  },

  dispose: function () {
    console.log('ExampleComponent with id: ' + this.title + ' has been disposed');
    this.remove();
  },

  _onUrlParamsChange: function () {
    message = 'This component doesnt reinstantiate when the url changes but instead gets new params passed through the urlParamsCollection: ';
    this.$output.html(message + '<pre>' + this._stringify(this.urlParamsCollection.toJSON())) + '</pre>';
  },

  _stringify: function (string) {
    return JSON.stringify(string, null, 2);
  },

  _highlightTemplateData: function (data) {
    for (var key in data) {
      if (data[key] && data[key].indexOf('undefined') < 0) {
        data[key] = '<b>' + data[key] + '</b>';
      }
    }
    return data;
  },

  _toggleFullsize: function (event) {
    $(event.currentTarget).parent().toggleClass('example-component--fullsize');
  }
});
