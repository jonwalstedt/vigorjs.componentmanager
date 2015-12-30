// Methods below is just used to display the filter on the example page
var activeFilterTemplate = _.template($('.active-filter-template').html()),
    isToggled = false;

$('.components-js__toggle').on('click', function () {
  $('.components-js__code').slideToggle(300);
  if (isToggled) {
    $(this).html('Show components.js');
  } else {
    $(this).html('Hide components.js');
  }
  isToggled = !isToggled;
});

showMsg = function (msg, filter) {
  var $activeFilter = $('.active-filter'),
      $examplesInfo = $('.examples-info');
  fltr = $.extend(true, {}, filter)
  filterObj = setFilterDefaults(fltr)
  options = filterObj.options
  delete filterObj.options

  $activeFilter.html(activeFilterTemplate({filterObj: filterObj, options: options}));

  $examplesInfo.html(msg);

  hljs.highlightBlock($activeFilter.get(0));
},

setFilterDefaults = function (filter) {
  filter = filter || {};
  filter.options = filter.options || {};
  if (filter.options.add === undefined)
    filter.options.add = 'true';

  if (filter.options.remove === undefined)
    filter.options.remove = 'true';

  if (filter.options.merge === undefined)
    filter.options.merge = 'true';

  if (filter.options.invert === undefined)
    filter.options.invert = 'false';

  if (filter.options.forceFilterStringMatching === undefined)
    filter.options.forceFilterStringMatching = 'false';

  filter.url = filter.url || 'undefined';
  filter.filterString = filter.filterString || 'undefined';
  filter.includeIfMatch = filter.includeIfMatch || 'undefined';
  filter.excludeIfMatch = filter.excludeIfMatch || 'undefined';
  filter.hasToMatch = filter.hasToMatch || 'undefined';
  filter.cantMatch = filter.cantMatch || 'undefined';

  filter.options.add = filter.options.add.toString();
  filter.options.remove = filter.options.remove.toString();
  filter.options.merge = filter.options.merge.toString();
  filter.options.invert = filter.options.invert.toString();
  filter.options.forceFilterStringMatching = filter.options.forceFilterStringMatching.toString();

  for (var key in filter) {
    if (filter[key] !== 'undefined' && key !== 'options') {
      filter[key] = '<b>' + filter[key] + '</b>';
    }
    if (filter[key] !== 'undefined' && key !== 'options' && key !== 'true' && key !== 'false') {
      filter[key] = '<b>"' + filter[key] + '"</b>';
    }
  }
  return filter;
}
