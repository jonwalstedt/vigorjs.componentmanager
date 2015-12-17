### <a name="parse"></a> parse

The parse method takes two parameters: a serialized settings object (created by calling componentManager.[serialize](#serialize)()) and a boolean to decide if it should update the current settings or just return a parsed settings object.

If you set the updateSetting boolean to true, it will update the current instance of the componentManager with the parsed settings object created from the serialized string (it will return the settings object). If it is set to false (**it defaults to false**) it will just return an object containing the parsed settings.

```javascript
var serializedSettings = componentManager.serialize();
    updateSettings = true,
    parsedSettings = componentManager.parse(serializedSettings, updateSettings);
```

Returns the parsed settings object.

See the [order/reorder](/examples/reorder-components) example.