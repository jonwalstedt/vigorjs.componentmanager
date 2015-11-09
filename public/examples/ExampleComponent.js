ExampleComponent = Backbone.View.extend({

  template: _.template($('.example-component-template').html()),

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
        urlParamsModel: this._stringify(args.urlParamsModel.toJSON()),
        args: this._stringify(args)
      };

    console.log('ExampleComponent with id ' + title + ' has been instantiated');
    this.title = title;
    this.templateData = this._highlightTemplateData(templateData);
    this.$el.css("background", args.background);
    this.urlParamsModel = args.urlParamsModel;
    this.listenTo(this.urlParamsModel, 'change', _.bind(this._onUrlParamsChange, this));
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
    message = 'This component doesnt reinstantiate when the url changes but instead gets new params passed through the urlParamsModel: ';
    this.$output.html(message + '<pre>' + this._stringify(this.urlParamsModel.toJSON())) + '</pre>';
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
  }
});
