### <a name="iframe-component"></a> IframeComponent

By setting a url as src attribute on a [instanceDefinition](#instance-definitions) the componentManager will create an instance of the IframeComponent class to load the url in an iframe.

The IframemComponent is exposed on the Vigor object so it's easy to extend it and create custom IframeComponents if additional logic is needed.

The IframeComponent extends Backbone.View and have the following default attributes:

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
<iframe seamless="seamless" scrolling="false" border="0" frameborder="0" width="400" class="vigor-component--iframe vigor-component" src="http://www.google.com"></iframe>
```

The IframeComponent class exposed the following public methods:

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
        **initialize**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **addListeners**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **removeListeners**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **render**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **dispose**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **postMessageToIframe**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **receiveMessage**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **onIframeLoaded**
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>
  </tbody>
</table>

See the [IframeComponent example](/examples/iframe-components/).