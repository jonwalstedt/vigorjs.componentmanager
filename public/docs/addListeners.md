### <a name="addListeners"></a> addListeners

The addListeners method will wire up the componentManager to start listening for changes on conditions, componentDefinitions, instanceDefinitions and act upon those changes. It will also start triggering its own events.

This method will be called when initializing the componentManager, so you do not need to run this method unless you previously have removed the event listeners using [removeListeners](#removeListeners).

The addlisteners method returns the componentManager instance.