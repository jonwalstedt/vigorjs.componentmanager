### <a name="addComponentDefinitions"></a> addComponentDefinitions

The addComponentDefinitions method is used to add componentDefinitions on the fly after initialization. It takes an [componentDefinition](#component-definitions) object or an array of componentDefinition objects.

When adding new componentDefinitions the componentManager will immediately do refresh with the currently applied filter to add any new instances to the DOM.

```javascript
componentManager.addComponentDefinitions([
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
