### <a name="active-instance-events"></a> Active instance events
The componentManager triggers events when adding, removing or changing active instances (instances that are currently being added, removed or changed by the componentManager in the DOM). To use these events listen for either `add`, `remove` or `change` on the componentManager instance. The callback will get the affected component instance and an array with all active instances as arguments.

```javascript
componentManager.on('add', function (addedInstance, allActiveInstances) {});

componentManager.on('change', function (changedInstance, allActiveInstances) {});

componentManager.on('remove', function (removedInstance, allActiveInstances) {});

// or

componentManager.on(componentManager.EVENTS.ADD, function (addedInstance, allActiveInstances) {});

componentManager.on(componentManager.EVENTS.CHANGE, function (changedInstance, allActiveInstances) {});

componentManager.on(componentManager.EVENTS.REMOVE, function (removedInstance, allActiveInstances) {});
```
