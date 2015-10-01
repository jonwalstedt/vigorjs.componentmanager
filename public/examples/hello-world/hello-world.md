## Hello World

Definitions of components and inctances of components are parsed and then filtered on the componentManager. Whenever the refresh method is called any instance that matches the passed filters will be instantiated and added to the target, all instances that doesn't match the passed filter be disposed.

In this example the hello-world-component is set to match the urlPattern "add-hello-world" and the router will refresh the componentManager with the current url on any url change. Click the links below to see the result, and take a look at the js files to see the setup.

- [Add Hello World](#add-hello-world)
- [Remove Hello World](#remove-hello-world)