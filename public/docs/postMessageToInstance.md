### <a name="postMessageToInstance"></a> postMessageToInstance

The postMessageToInstance takes an instanceDefinition id as first argument and a message (can be anything) as a second argument. The message will be forwarded to the the receiveMessage method on the instance of the instanceDefinition matching the passed instanceDefinition id (the instance must in the DOM).

```javascript
// The example component with the receiveMessage method.
var MyComponent = Backbone.View.extend({
  render: function () {...},
  dispose: function () {...},
  receiveMessage: function (message) {
    console.log(message);
  }
});

// Register the component and one instance of that component
componentSettings = {
  components: [{
    id: 'my-component',
    src: MyComponent
  }],
  instances: [{
    id: 'my-instance',
    componentId: 'my-component',
    targetName: 'body'
  }]
}

// Initialize the componentManager with the componentSettings object
componentManager.initialize(componentSettings);

// Add the instance to the DOM
componentManager.refresh();

// Post a message to the instance
var instanceDefinitionId = 'my-instance',
    message = {
      im: 'a message'
    };

componentManager.postMessageToInstance(instanceDefinitionId, message);
```
