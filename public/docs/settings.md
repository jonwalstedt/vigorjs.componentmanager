### <a name="settings"></a>Available settings
To get started with the componentManager you need to setup the settings object which you will pass to the initialize function - typically during bootstrap of your application.

There are a couple of different ways to structure the settings object and the most straight forward setup has the following structure:
```javascript
settings = {
  $context: '',
  componentClassName: '',
  targetPrefix: '',
  listenForMessages: false,
  componentSettings: {
    conditions: {},
    components: [],
    instances: []
  }
}

componentManager.initialize(settings);
```

And here is an example of how it could look with some content:
```javascript
settings = {
  $context: '.my-app',
  componentClassName: 'my-component',
  targetPrefix: 'my-component-area',
  componentSettings: {
    conditions: {
      isValWithinLimit: function (filter, args) {
        var limit = 400;
        return args.val < limit;
      }
    },

    components: [
      {
        id: 'my-component',
        src: MyComponent
      },
      {
        id: 'my-second-component',
        src: MySecondComponent
      }
    ],

    instances: [
      {
        id: 'instance-1',
        componentId: 'my-component',
        targetName: 'my-component-area--header',
        urlPattern: 'foo/:bar',
        order: 1,
        args: {
          val: this.getVal()
        }
      },
      {
        id: 'instance-2',
        componentId: 'my-second-component',
        targetName: 'my-component-area--main',
        urlPattern: 'bar/:baz(/:qux)'
      }
    ]
  }
}

componentManager.initialize(settings);
```

If you dont want to change the defaults for $context, componentClassName, targetPrefix and listenForMessages you pass in only the componentSettings part of the settings object:
```javascript
componentSettings: {
  conditions: {},
  components: [],
  instances: []
}

componentManager.initialize(componentSettings);
```
