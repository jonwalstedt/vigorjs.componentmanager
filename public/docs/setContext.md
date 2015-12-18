### <a name="setContext"></a> setContext

The setContext method takes a DOM element selector or a jQuery object as argument. The element with the passed selector will be used as context, if no argument is passed it will default to use the body as context.

```javascript
componentManager.setContext($('.my-app'));
```

or

```javascript
componentManager.setContext('.my-app');
```
