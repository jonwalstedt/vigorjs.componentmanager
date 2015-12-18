### <a name="removeComponentDefinition"></a> removeComponentDefinition

The removeComponentDefinition method takes a componentDefinition id or an array with component ids as argument. It will remove the componentDefinition with the passed id and all instenceDefinitions that are referencing that componentDefinition.

```javascript
componentManager.removeComponentDefinition('my-component');
```

The removeComponentDefinition method returns the componentManager instance.