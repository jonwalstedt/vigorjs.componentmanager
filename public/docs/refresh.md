### <a name="refresh"></a> refresh

The refresh method can be called with or without a [filter](#filter).

When calling refresh with a filter all instances that doesn't match that filter will be disposed and removed from the DOM and all instances that does match the filter will be added.

If calling the refresh method without a filter all instances will be created and added to the DOM (assuming their component-areas are available).

Example:

```javascript
componentManager.updateSettings({
  url: 'foo/1'
  options: {
    remove: false
  }
});
```

The refresh method returns a promise that will be resolved (after any asynchronous components has been loaded) with an object containing:

```javascript
returnData = {
  filter: {...} // The current filter (object)
  activeInstances: [...] // all active instances (array)
  activeInstanceDefinitions: [...] // all activeInstanceDefinitions (array)
  lastChangedInstances: [...] // the last changed instances (array)
  lastChangedInstanceDefinitions: [...] // the last changed instanceDefinitions (array)
}
```
