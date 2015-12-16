### <a name="updateSettings"></a> updateSettings

The updateSettings method updates the componentManager with new settings after initialization. It should be called with the [settings object](#settings).

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

componentManager.updateSettings(settings);
```
