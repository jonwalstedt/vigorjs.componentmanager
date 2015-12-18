### <a name="addInstanceDefinitions"></a> addInstanceDefinitions

The addInstanceDefinitions method is used to add instanceDefinitions on the fly after initialization. It takes an [instanceDefinition](#instance-definitions) object or an array of instanceDefinition objects.

When adding new instanceDefinitions the componentManager will immediately do refresh with the currently applied filter to add any new instances to the DOM.

```javascript
componentManager.addInstanceDefinitions([
  {
    id: 'instance-1',
    componentId: 'my-first-component',
    targetName: '.my-component-area--header',
    urlPattern: 'foo/:bar'
  },
  {
    id: 'instance-2',
    componentId: 'my-second-component',
    targetName: '.my-component-area--header',
    urlPattern: 'bar/:foo'
  }
]);
```
