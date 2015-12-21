### <a name="setComponentClassName"></a> setComponentClassName

The setComponentClassName method sets the class name (or class names) that will be added to each instance created by the componentManager. It takes a string (the class name to use - without a period) as an argument. If multiple classes should be added separate them with a space like this: "my-first-class-name my-second-class-name".

This method will be called internally during initialization to update the componentClassName from the componentClassName property in the [settings ojbect](#settings) (if it is set). You usually do not have to call this method after initialization unless you intend to change the class names on the fly, in that case the class names will be swapped immediately on all active instances.

```javascript
componentManager.setComponentClassName('my-component');
```

The componentClassName defaults to 'vigor-component' and it returns the componentManager instance.