### <a name="setContext"></a> setContext

The setContext method takes a DOM element selector or a jQuery object as first argument. The element with the passed selector will be used as context, if no argument is passed it will default to use the body as context.

When updating the context on the fly the componentManager will dispose all active instances and try to recreate and add them within the new context.


```javascript
componentManager.setContext($('.my-app'));
```

or

```javascript
componentManager.setContext('.my-app');
```

The setContext method returns the componentManager instance.