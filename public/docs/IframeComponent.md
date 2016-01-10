### <a name="iframe-component"></a> IframeComponent

By setting a url as src attribute on a [instanceDefinition](#instance-definitions) the componentManager will create an instance of the IframeComponent class to load the url in an iframe.

The IframemComponent is exposed on the Vigor object so it's easy to extend it and create custom IframeComponents if additional logic is needed.

The IframeComponent extends Backbone.View and have the following default attributes (the Backbone.View attributes property):

```javascript
attributes: {
  seamless: 'seamless',
  scrolling: no,
  border: 0,
  frameborder: 0
}
```

If you pass a iframeAttributes object in the args object passed to the [instanceDefinition](#instance-definitions) those properties will be merged into the attributes of the IframeComponent class and added to the DOM element. See example below.

```javascript
componentManager.initialize({
  components: [{
    id: 'my-component-definition',
    src: 'http://www.google.com'
  }],
  instances: [{
    id: 'my-instance-definition',
    componentId: 'my-component-definition',
    args: {
      iframeAttributes: {
        width: 400
      }
    },
    targetName: 'body'
  }]
});

componentManager.refresh();
```

This will add an IframeComponent instance with the following iframe markup:

```html
<iframe
  seamless="seamless"
  scrolling="false"
  border="0"
  frameborder="0"
  width="400"
  class="vigor-component--iframe
  vigor-component"
  src="http://www.google.com">
</iframe>
```

The IframeComponent exposes the public property targetOrigin which defaults to `http://localhost:7070` which you override by passing the desired targetOrigin value in the args object (see the [targetOrigin documentation](https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage)):

```javascript
componentManager.initialize({
  components: [{
    id: 'my-component-definition',
    src: 'http://www.google.com'
  }],
  instances: [{
    id: 'my-instance-definition',
    componentId: 'my-component-definition',
    args: {
      targetOrigin: 'http://www.mydomain.com',
      iframeAttributes: {
        width: 400
      }
    },
    targetName: 'body'
  }]
});

componentManager.refresh();
```

#### Cross origin message to a instance
To send messages to instances cross origin using the postMessage api you need to set the origin in the whitelistedOrigins property of the componentManager. Each message needs to have an 'id' property with the id of the instance which the message should be forwarded to. It also needs the 'message' property containing the message to forward and the 'recipient' property set to 'vigorjs.componentmanager'.

See example below.

From within the iframed content:
```javascript
var data = {
  recipient: 'vigorjs.componentmanager',
  id: 'an-instance-id'
  message: 'the message to forward'
},
targetOrigin = 'http://localhost:3000';
parent.postMessage(data, targetOrigin);
```

The targetOrigin needs to be registered within the whitelistedOrigins.
To see this in action view the IframeComponent examples: [IframeComponent example](/examples/iframe-components/)

The IframeComponent class exposes the following public methods:

<div class="docs-table-wrapper">
  <table class="docs-table">
    <thead>
      <tr>
        <th class="docs-table__column docs-table__column-1">Property</th>
        <th class="docs-table__column docs-table__column-2">Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="docs-table__column docs-table__column-1">
          `initialize`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The initialize method will call the addListeners method and set the this.src property if it was passed during instantiation.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `addListeners`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The addListeners method will add a listener for 'onload' on the iframe and call onIframeLoaded as a callback when the iframe is finished loading.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `removeListeners`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The removeListeners method will remove the 'onload' listener.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `render`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The render method will set the src attribute on the iframe and start loading it's content. It returns the instance for chainability.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `dispose`
        </td>
        <td class="docs-table__column docs-table__column-2">
          Dispose will call removeListeners and remove to remove event listeners and remove the element from the DOM.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `postMessageToIframe`
        </td>
        <td class="docs-table__column docs-table__column-2">
          This method will forward a message from the IframeComponent (Backbone.View) class into the contentWindow of the iframe using the postMessage api. It will also pass along the targetOrigin property of the IframeComponent.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `receiveMessage`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The default implementation is a noop
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `onIframeLoaded`
        </td>
        <td class="docs-table__column docs-table__column-2">
          The default implementation is a noop
        </td>
      </tr>
    </tbody>
  </table>
</div>

See the [IframeComponent example](/examples/iframe-components/).