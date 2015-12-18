### <a name="updateComponentDefinitions"></a> updateComponentDefinitions

The updateComponentDefinitions method is used to update existing componentDefinitions on the fly after initialization. It actually calls [addComponentDefinitions](#addComponentDefinitions) so it works exactly the same, if you pass an object with an id that is already registered in the componentManager it will update that object with the properties in the passed object.

When updating componentDefinitions the componentManager will immediately do refresh with the currently applied filter to add/readd any changed instances to the DOM.

```javascript
componentManager.updateComponentDefinitions([
  {
    id: 'my-first-component',
    src: 'components/my-first-component'
  },
  {
    id: 'my-second-component',
    src: 'components/my-second-component',
    conditions: 'isLoggedIn'
  }
]);
```
