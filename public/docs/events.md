### <a name="component-definition-events"></a> ComponentDefinition Events
The componentManager triggers events when adding, removing or changing componentDefinitions, instanceDefinitions and activeInstanceDefinitions. The callback will get the affected definition and an array with all registered definitions as arguments.

```javascript
componentManager.on('component-add', function (addedComponentDefinition, allComponentDefinitions) {});

componentManager.on('component-change', function (changedComponentDefinition, allComponentDefinitions) {});

componentManager.on('component-remove', function (removedComponentDefinition, allComponentDefinitions) {});

// or

componentManager.on(componentManager.EVENTS.COMPONENT_ADD, function (addedComponentDefinition, allComponentDefinitions) {});

componentManager.on(componentManager.EVENTS.COMPONENT_CHANGE, function (changedComponentDefinition, allComponentDefinitions) {});

componentManager.on(componentManager.EVENTS.COMPONENT_REMOVE, function (removedComponentDefinition, allComponentDefinitions) {});
```

### <a name="instance-definition-events"></a> InstanceDefinition Events

```javascript
componentManager.on('instance-add', function (addedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on('instance-change', function (changedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on('instance-remove', function (removedInstanceDefinition, allInstanceDefinitions) {});

// or

componentManager.on(componentManager.EVENTS.INSTANCE_ADD, function (addedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.INSTANCE_CHANGE, function (changedInstanceDefinition, allInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.INSTANCE_REMOVE, function (removedInstanceDefinition, allInstanceDefinitions) {});
```

### <a name="active-instance-events"></a> Active instance events
```javascript
componentManager.on('add', function (activeInstanceDefinition, allActiveInstanceDefinitions) {});

componentManager.on('change', function (changedActiveInstanceDefinition, allActiveInstanceDefinitions) {});

componentManager.on('remove', function (removedActiveInstanceDefinition, allActiveInstanceDefinitions) {});

// or

componentManager.on(componentManager.EVENTS.ADD, function (activeInstanceDefinition, allActiveInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.CHANGE, function (changedActiveInstanceDefinition, allActiveInstanceDefinitions) {});

componentManager.on(componentManager.EVENTS.REMOVE, function (removedActiveInstanceDefinition, allActiveInstanceDefinitions) {});
```
