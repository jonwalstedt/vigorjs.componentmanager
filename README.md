# VigorJS ComponentManager

The VigorJS ComponentManager is a small framework intended to help decouple and simplify the application structure of large scale [Backbone](http://backbonejs.org/) applications.

- ## What does it do?
  After initializing the ComponentManager with your [settings](/docs/#settings) it will load, instantiate and add all your components to the DOM simply by calling the [refresh](/docs/#refresh) method with a [filter](/docs/#filter). Any components that doesn't match the passed filter will be disposed (depending on which [options](/docs/#options) you use).

- ## Why?
  As a application grows in in size it's easy to let different parts of the application get tangled up into each other. Components that are tightly coupled with the application framework or other components are harder to reuse or extend. The ComponentManager tries to solve this by separating your components from the application logic itself.

- ## Getting started
  To get started head over to the [getting started](/docs/#getting-started) section or look through the [examples](/examples) and their setup.
