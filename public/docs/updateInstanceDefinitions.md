### <a name="updateInstanceDefinitions"></a> updateInstanceDefinitions

The updateInstanceDefinitions method is used to update existing instanceDefinitions on the fly after initialization. It actually calls [addInstanceDefinitions](#addInstanceDefinitions) so it works exactly the same, if you pass an object with an id that is already registered in the componentManager it will update that object with the properties in the passed object.

When updating instanceDefinitions the componentManager will immediately do refresh with the currently applied filter to add/readd any changed instances to the DOM.

```javascript
componentManager.updateInstanceDefinitions([
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
