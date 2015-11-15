### <a name="introduction"></a> Introduction

The componentManager is a small UMD module thats manages components and instances of components. The main purpose of the component manager is to **decouple large scale Backbone applications**. By letting the componentManager handle instantiation of components through out your application your main application can be alot smaller and without hardcoded dependencies to components. This makes it alot easier to build reusable components that does not get tangled up in eachother or the application logic itself. This will also make it easier to maintain your application over time.

In the best of worlds the application in it self should not have to be aware of what components are instantiated and where they are placed. The components should be built to be able to handle them self (**loose coupling**) and to gather data from a shared data layer.

The componentManager lets you configure [componentDefinitions](/docs/#component-definitions), [instanceDefinitions](/docs/#instance-definitions) and [conditions](/docs/#conditions) for your application and then creates instances and adds them to the DOM whenever they are needed. All you have to do is call the [refresh](/docs/#refresh) method with your [filter](/docs/#filter). When a instance matches the filter it will be created and if not (if it previously was created) it will be properly disposed.

To see the different features and filters in action go to the [examples page](/examples) or for a more complex example see the [example app](/examples/example-app).