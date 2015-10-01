## Filter components by url
You can filter components by specifying a url pattern for your instance definition and then add the url you want to filter on to the filter passed to the refresh method.

You can use any of the url patterns that Backbone supports as url pattern on your instance definition. The componentManager will filter out components that matches the url passed to the filter and instantiate them with url params passed to the constructor function.

Try filtering the components using the links below
- [Reset](#)
- [Passing arguments](#passing-arguments/news/political) ex: passing-arguments/:type/:id
- [Passing arguments](#passing-arguments/news/domestic) ex: passing-arguments/:type/:id
- [Splats](#splat/a/lot/of/sub/sections/in/the/url) ex: splat/*path
- [Optional Arguments 1](#optional/arguments) ex: optional/:section(/:subsection)
- [Optional Arguments 2](#optional/arguments/can-be-optional) ex: optional/:section(/:subsection)
- [Optional Arguments 3](#optional/arguments/can-be-optional/my-id) ex: optional/:section(/:subsection)(/:id)
- [Global](#a-random-url) ex: all urls
