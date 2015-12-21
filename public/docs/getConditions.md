### <a name="getConditions"></a> getConditions

Returns the condition object from the [settings object](#settings). If any conditions have been added after initialization those conditions will also be returned in the same object. Conditions can be added either by adding them to the conditions object in the [settings object](#settings) or by using the [addConditions](#addConditions) method.

See [conditions](#conditions) for more information about how to use conditions in the componentManager.

```javascript
var conditions = componentManager.getConditions();
```
