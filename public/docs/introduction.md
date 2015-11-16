### <a name="introduction"></a> Introduction

The componentManager is a small UMD module thats manages instantiation of components and the main purpose of the componentManager is to help **decouple large scale Backbone applications**. By letting the componentManager handle instantiation of components throughout your application your main application can be smaller, cleaner and without hardcoded dependencies to components. This makes it alot easier to build reusable components that does not get tangled up in eachother or the application logic itself. This will also make it easier to scale and maintain your application over time.

In the best of worlds the application in it self should not have to be aware of what components are instantiated and where they are placed. The components them selfs should in turn not be aware of the application or eachother. They should be built to be able to handle them self (**loose coupling**) and to gather data from a shared data layer.

The componentManager lets you configure [componentDefinitions](/docs/#component-definitions) and [instanceDefinitions](/docs/#instance-definitions) for your application and then creates instances and adds them to the DOM whenever they are needed. All you have to do is call the [refresh](/docs/#refresh) method with your [filter](/docs/#filter). When a instance matches the filter it will be created and if not (if it previously was created) it will be properly disposed.

In the componentManager each instanceDefinition can have their own defined urlPatterns (routes) and other filters and [conditions](/docs/#conditions) to decide when to create or dispose instances.

To see the different features and filters in action go to the [examples page](/examples) or for a more complex example see the [example app](/examples/example-app).