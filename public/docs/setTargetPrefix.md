### <a name="setTargetPrefix"></a> setTargetPrefix

The setTargetPrefix method takes a string (the prefix to use - without a period) as an argument.

The setTargetPrefix method sets the class prefix that will be used to prefix the targetName property on instanceDefinitions with. The prefixed targetName is the element class name that will be used to find the DOM elements where to add instances ([componentAreas](#component-areas)).


The structure of the class name that is needed on componentAreas is {{prefix}}--{{name}}, see example below:

```javascript
componentManager.setComponentClassName('my-component-area');

componentManager.addInstanceDefinition({
  id: 'my-instance',
  componentId: 'my-component',
  targetName: 'main'
})
```

And the markup would look like this with the prefixed class:
```html
<div class="my-component-area--main"><div>
```

In the example above the prefix is set to 'my-component-area' and the name of the component area is 'main'. When using the method setTargetPrefix to change the targetPrefix the componentManager will try to move all active instances that has been added to component areas to component ares with the new prefix, if there are no such component areas the instances will be disposed.


This method will be called internally during initialization to update the targetPrefix from the targetPrefix property in the [settings ojbect](#settings) (if it is set). You usually do not have to call this method after initialization unless you intend to change the targetPrefix on the fly.

The targetPrefix defaults to 'component-area' and the method returns the componentManager instance.

