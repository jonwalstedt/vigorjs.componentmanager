### <a name="component-definition-events"></a> ComponentDefinition Events
The componentManager triggers events when adding, removing or changing componentDefinitions. To use these events listen for either '**component-add**', '**component-remove**' or '**component-change**' on the componentManager instance. The callback will get the affected componentDefinition and an array with all registered componentDefinitions as arguments.

```javascript
componentManager.on('component-add', function (addedComponentDefinition, allComponentDefinitions) {});

componentManager.on('component-change', function (changedComponentDefinition, allComponentDefinitions) {});

componentManager.on('component-remove', function (removedComponentDefinition, allComponentDefinitions) {});

// or

componentManager.on(componentManager.EVENTS.COMPONENT_ADD, function (addedComponentDefinition, allComponentDefinitions) {});

componentManager.on(componentManager.EVENTS.COMPONENT_CHANGE, function (changedComponentDefinition, allComponentDefinitions) {});

componentManager.on(componentManager.EVENTS.COMPONENT_REMOVE, function (removedComponentDefinition, allComponentDefinitions) {});
```
