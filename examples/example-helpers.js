// Methods below is just used to display the filter on the example page
var exampleHelpers = {

  activeFilterTemplate: undefined,
  $activeFilter: undefined,
  $examplesInfo: undefined,
  $componentsToggle: undefined,
  $componentsCode: undefined,
  isToggled: false,

  initialize: function () {
    this.$activeFilter = $('.active-filter');
    this.$examplesInfo = $('.examples-info');
    this.$componentsToggle = $('.components-js__toggle');
    this.$componentsCode = $('.components-js__code');
    this.activeFilterTemplate = _.template($('.active-filter-template').html())

    this.$componentsToggle.on('click', _.bind(this._onComponentsToggleClick, this));


    $('.hljs').each(function () {
      hljs.highlightBlock(this);
    });
  },

  stringify: function (object) {
    function replacer(key, value) {
      if (typeof value === 'undefined') {
        return 'undefined';
      }
      if (typeof value !== 'object') {
        return '<b>' + value + '</b>';
      }
      return value;
    }
    return JSON.stringify(object, replacer, 2);
  },

  showMsg: function (msg, filter) {
    var activeFilter = {};

    if (!filter) {
      if (Vigor && Vigor.componentManager && Vigor.componentManager._filterModel) {
        activeFilter = Vigor.componentManager._filterModel.toJSON()
      }
    } else {
      activeFilter = filter;
    }

    activeFilter = this.stringify(activeFilter);

    this.$activeFilter.html(this.activeFilterTemplate({activeFilter: activeFilter}));
    this.$examplesInfo.html(msg);

    this.$activeFilter.each(function () {
      var $pre = $(this).find('code');
      hljs.highlightBlock($pre.get(0));
    });
  },

  _onComponentsToggleClick: function () {
    this.$componentsCode.slideToggle(300);
    if (this.isToggled) {
      this.$componentsToggle.html('Show components.js');
    } else {
      this.$componentsToggle.html('Hide components.js');
    }
    this.isToggled = !this.isToggled;
  }
};

exampleHelpers.initialize();

