### <a name="dispose"></a> dispose

The dispose method calls [clear](#clear) which clears out all data and stored settings. In addition it will unset all internal models and collections it will also call [removeListeners](#removeListeners) which removes all eventlisteners.

When disposing the componentManager all active instances will also be disposed.
