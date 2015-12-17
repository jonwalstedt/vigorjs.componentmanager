### <a name="serialize"></a> serialize

The serialize method will return the current state of the componentManagers settings object as a string that then can be read back by the parse method.

The serialized string will not contain any applied filters but it will contain the original settings and any conditions, componentDefinitions, instanceDefinitions or other settings that have been changed/added/removed on the fly since initialization.


```javascript
var serializedSettings = componentManager.serialize();
```

Returns the current state of the componentManagers settings object as a string.

See the [order/reorder](/examples/reorder-components) example.