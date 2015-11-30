## Filter components by url
You can filter components by specifying a url pattern for your instance definition and then add the url fragment you want to filter on to the filter passed to the refresh method.

You can use any of the url patterns that Backbone supports as url pattern on your instance definition. The componentManager will filter out components that matches the url fragment passed to the filter and instantiate them with url params passed to the constructor function.

