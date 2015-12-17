### <a name="clear"></a> clear

The clear method removes all registered conditions, componentDefinitions and instanceDefinitions. It will also clear any active filters and restore componentClassName, targetPrefix to their default values. If a context has been registered then that will be cleared out as well.

When clearing the componentManager all active instances will be disposed.

Returns the componentManager instance.
