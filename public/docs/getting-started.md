### <a name="getting-started"></a> Getting started

The componentManager is a simple way to handle the life cycle of instances of components within your application. By adding a settings object containing definitions of components and instances of those components the componentManager knows when and where to create and add the instances. All you need to do is call the refresh method with a filter that informs the componentManager of the state of the application.

The most common use case would be to hook up the componentManager to the router and call refresh with a url filter every time the url changes. Or to create your own filter model and call refresh on the componentManager whenever any of the filters changes.

When you call refresh with a filter the componentManager will filter out any matching [instanceDefinitions](#instance-definitions) and create an instance of the [componentDefinition](#component-definitions) that the instanceDefinition is referencing.

As a part of the filtering process the componentManager checks that the [componentArea](#component-areas) that the instanceDefinition targets is available, if not the instance will not be created.

See the simple example below (in this example the component will be required from the path 'components/hello-world', too see how to do a AMD or CommonJS setup see the [AMD example](../examples/amd-requirejs/) or [CommonJS example](../examples/commonjs-browserify/)).

The componentArea in the markup
```html
<div class="my-app">
  <section class="component-area--main"></section>
</div>
```

Initialize the componentManager with the needed settings:
```javascript
define(function (require) {
  'use strict';

  var Backbone = require('backbone'),
      componentManager = require('vigor').componentManager,
      Router = require('./Router');

  componentManager.initialize({
    context: '.my-app',
    componentSettings: {
      components: [{
        id: 'hello-world-component',
        src: 'components/hello-world'
      }],
      instances: [{
        id: 'hello-world-instance',
        componentId: 'hello-world-component',
        targetName: '.component-area--main',
        urlPattern: 'hello-world'
      }]
    }
  });

  new Router();
  Backbone.history.start();
});
```

Hook up router to call refresh whenever the url updates.
```javascript
define (function (require) {
  'use strict';
  var
    Backbone = require('backbone'),
    componentManager = require('vigor').componentManager,
    Router = Backbone.Router.extend({
      routes: {
        '*action': '_onAllRoutes',
        '*notFound': '_onAllRoutes'
      },

      _onAllRoutes: function () {
        Vigor.componentManager.refresh({
          url: Backbone.history.fragment
        });
      }
  });
  return Router;
});
```

Our simple example component (to learn more about components view the [Components](#components) section below):
```javascript

define (function (require) {
  'use strict';
  var HelloWorld
      Backbone = require('backbone');

  HelloWorld = Backbone.View.extend({

    render: function () {
      this.$el.html('Hello World!');
    },

    dispose: function () {
      this.remove();
    }

  });

  return HelloWorld;
});
```

After setting this up your hello-world component will be required in and instantiated whenever you go to the url 'http://yourdevserver/#hello-world'. If you go to some other url that instance will be disposed and removed from the DOM.

To scale this up is basically just to add your layout and expand your [settings](#settings) object with more [componentDefinitions](#component-definitions) and [instanceDefinitions](#instance-definitions). To see a more advanced example see the [Example app](../examples/example-app).

To see it in action go to the [hello world](../examples/hello-world) example.
