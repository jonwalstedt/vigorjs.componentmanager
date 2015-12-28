### <a name="component-areas"></a> Component Areas

Component areas are the DOM elements where instances of components will be placed. The component areas can be any element but they have to have a class that matches the class defined in your instanceDefinitions targetName property plus the targetPrefix ex. `component-area--main` where `component-area` is the default prefix.

The prefix can be changed to anything you like by setting the targetPrefix property on the [settings object](#settings) to the string you would like to use as a prefix.

See example below.

```javascript
settings = {
  targetPrefix: 'my-component-area',
  componentSettings: {
    components: [
      {
        id: 'my-component',
        src: 'components/my-component'
      }
    ],
    instances: [
      {
        id: 'instance-1',
        componentId: 'my-component',
        targetName: '.my-component-area--main',
        urlPattern: 'foo/:bar'
      }
    ]
  }
}

componentManager.initialize(settings);
```

or using the [alternative structure](#alternative-structure) it would look like this:

```javascript
settings = {
  targetPrefix: 'my-component-area',
  componentSettings: {
    components: [
      {
        id: 'my-component',
        src: 'components/my-component'
      }
    ],
    targets: {
      main: [
        {
          id: 'instance-1',
          componentId: 'my-component',
          urlPattern: 'foo/:bar'
        }
      ]
    }
  }
}

componentManager.initialize(settings);
```


In the examples above the prefix is set to `'my-component-area'` which means that all DOM elements that should receive instances by the componentManager should have class names that starts with `'my-component-area'`, ex: `class="my-component-area--main"` or `class="my-component-area--sidebar"` etc.

```html
<div class="my-component-area--main"></div>
```

Component areas does not have to be empty, they can contain elements that are not part of any instantiated components. If the order of these elements in relation to the created instance elements is important they should have an data-order attribute. Instances in the component manager gets the order attribute by setting the order property to the desired value.

See example below:

```javascript
settings = {
  targetPrefix: 'my-component-area',
  componentSettings: {
    components: [
      {
        id: 'my-component',
        src: 'components/my-component'
      }
    ],
    instances: [
      {
        id: 'instance-1',
        componentId: 'my-component',
        targetName: '.my-component-area--main',
        order: 3,
        urlPattern: 'foo/:bar'
      }
    ]
  }
}

componentManager.initialize(settings);
```

Markup
```html
<div class="my-component-area--main">
  <div class="im-not-a-component im-a-static-element" data-order="1"></div>
  <div class="im-not-a-component im-a-static-element" data-order="2"></div>
  <!-- instance-1 will end up here  -->
  <div class="im-not-a-component im-a-static-element" data-order="4"></div>
</div>
```

Note that if multiple elements have the same order value they will end up after each other in the order they was added.