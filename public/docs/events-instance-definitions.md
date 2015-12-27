### <a name="instance-definition-events"></a> InstanceDefinition Events
The componentManager triggers events when adding, removing or changing instanceDefinitions. To use these events listen for either '**instance-add**', '**instance-remove**' or '**instance-change**' on the componentManager instance. The callback will get the affected instanceDefinition and an array with all registered instanceDefinitions as arguments.


```javascript
componentManager.on('instance-add', function (addedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on('instance-change', function (changedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on('instance-remove', function (removedInstanceDefinition, allInstanceDefinitions) {});

// or

componentManager.on(componentManager.EVENTS.INSTANCE_ADD, function (addedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.INSTANCE_CHANGE, function (changedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.INSTANCE_REMOVE, function (removedInstanceDefinition, allInstanceDefinitions) {});
```
