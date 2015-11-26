### <a name="introduction"></a> Introduction

The componentManager is a small UMD module that manages instances within your application. The main purpose of the componentManager is to help **decouple large scale Backbone applications** by letting it handle instantiation and disposal of components depending on different filters.

A common approach when building a Backbone application is to have a router that decides which page views to create when the url changes. Then the page create instances of the components that should be rendered on that page, and the components might create subcomponents and so on. The problem with this approach is that, as the application grows, components and pages easily gets tightly coupled (the page might add eventlisteners to its components, pass data back and forth between instances and the page it self, etc.) and suddenly it is almost impossible to reuse a component in another part of the application.

With the componentManager you can just call the refresh method and it will add the components in the correct place for you. No need to manually create instances on different pages, actually no need to have pages at all.

The componentManager lets you configure [componentDefinitions](/docs/#component-definitions) and [instanceDefinitions](/docs/#instance-definitions) for your application and then creates instances and adds them to the DOM whenever they are needed. All you have to do is call the [refresh](/docs/#refresh) method with your [filter](/docs/#filter). When a instance matches the filter it will be created and if not (if it previously was created) it will be properly disposed.

In the componentManager each instanceDefinition can have their own defined urlPatterns (routes) and other filters and [conditions](/docs/#conditions) to decide when to create or dispose instances.

By doing this your application can be smaller and cleaner. It makes it a lot easier to build reusable components that does not get tangled up in each other or the application logic itself. This will also make it easier to scale and maintain your application over time.

To see the different features and filters in action go to the [examples page](/examples) or for a more complex example see the [example app](/examples/example-app).