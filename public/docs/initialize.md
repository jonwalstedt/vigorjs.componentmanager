### <a name="initialize"></a> initalize

The componentManagers initialize method registers [componentDefinitons](#component-definitions) and [instanceDefinitions](#instance-definitons) and should be called with the [settings object](#settings) before you can start use the componentManager.

Example (using the [alternative structure](#alternative-structure)):

```javascript
settings = {
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

Initialize returns the componentManager instance.