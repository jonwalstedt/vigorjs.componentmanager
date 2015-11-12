### <a name="settings"></a>The settings object
To get started with the componentManager you need to setup the settings object which you will pass to the initialize function - typically during bootstrap of your application.

There are a couple of different ways to structure the settings object and the most straight forward setup has the following structure (example below is using the default values):
```javascript
settings = {
  context: 'body',
  componentClassName: 'vigor-component',
  targetPrefix: 'component-area',
  listenForMessages: false,
  componentSettings: {
    conditions: {},
    components: [],
    instances: []
  }
}
```

The settings object can contain the four properties above and the componentSettings object. The componentSettings object can contain the conditions object, the components array and the settings array. None of these are mandatory either but without components and instances the componentManager wont do much (they can be added on the fly later if you do not want to add them when initializing the componentManager).

The componentsArray should contain one or multiple [componentDefinition](#component-definitions) objects and the instances array (or targets object - see alternative structure below) should contain one or multiple [instanceDefinition](#instance-definitions) objects.

And here is an example of how it could look with some content:
```javascript
settings = {
  context: '.my-app',
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
        targetName: '.my-component-area--header',
        urlPattern: 'foo/:bar',
        order: 1,
        args: {
          val: this.getVal()
        }
      },
      {
        id: 'instance-2',
        componentId: 'my-second-component',
        targetName: '.my-component-area--main',
        urlPattern: 'bar/:baz(/:qux)'
      }
    ]
  }
}

componentManager.initialize(settings);
```

#### <a name="alternative-structure"></a> Alternative structure
If you like to group your instances under their targets that is also possible by using the structure below. This strucure does not allow you to pass the target selector for each instance your self which might be good if you are using this as a way for third party users to add components to your appliction (ex ads).

```javascript
settings = {
  context: 'body',
  componentClassName: 'vigor-component',
  targetPrefix: 'component-area',
  listenForMessages: false,
  componentSettings: {
    conditions: {},
    components: [],
    targets: {}
  }
}
```

And here is an example of how this could look with some content:
```javascript
settings = {
  context: '.my-app',
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
    targets: {
      header: [
        {
          id: 'instance-1',
          componentId: 'my-component',
          urlPattern: 'foo/:bar',
          order: 1,
          args: {
            val: this.getVal()
          }
        }
      ]
      main: [
        {
          id: 'instance-2',
          componentId: 'my-second-component',
          urlPattern: 'bar/:baz(/:qux)'
        }
      ]
    }
  }
}

componentManager.initialize(settings);
```
In this case each of the target keys would be used as a part the selector to use for all of the instanceDefinitions within that array. The other part of the selector would be the targetPrefix so in the examples above any instanceDefiniton that would be part of the array for "header" would have the targetName set to **"component-area--header"**, for "main" it would be **"component-area--main"** and so on.

#### Skip defaults
If you dont want to change the defaults for context, componentClassName, targetPrefix and listenForMessages you pass in only the componentSettings part of the settings object:
```javascript
componentSettings: {
  conditions: {},
  components: [],
  instances: []
}
```

