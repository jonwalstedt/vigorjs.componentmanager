### <a name="other-settings"></a> Other settings
The settings object can contain four properties except for the componentSettings object: context, componentClassName, targetPrefix and listenForMessages. See specifications and example below.

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
        `context` String / jQuery object
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The context property of the settings object should be either a element selector as a string (ex. '#my-id' or '.my-class') or a jQuery object (ex $('.my-element')). The element will be used as context for the componentManager and all DOM related actions will be kept within that context.</p>

        <p>The context defaults to `'body'`.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        `componentClassName` String
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The componentClassName should be a string and it will be used as a class on each instance created by the componentManager.</p>

        <p>The componentClassName defaults to '`vigor-component`'.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        `targetPrefix` String
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The targetPrefix should be a string and it should prefix all [component-areas](#component-areas) that will receive instances by the componentManager. If you set your targetPrefix to be 'my-prefix' your component areas should have class names like 'my-prefix--header', 'my-prefix--main' etc.</p>

        <p>The targetPrefix defaults to `'component-area'`.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        `listenForMessages` Boolean
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The listenForMessages property is intended to be used when working with [IframeComponents](#iframe-component) and cross-origin communication using the `postMessage` method.</p>

        <p>By setting the listenForMessages to true the componentManager will start listening for incoming messages.</p>

        <p>The listenForMessages defaults to `false`.</p>
      </td>
    </tr>
  </tbody>
</table>

Example
```javascript
settings = {
  context: '.my-app',
  componentClassName: 'my-component',
  targetPrefix: 'my-component-area',
  listenForMessages: true,
  componentSettings: {
    conditions: {...},
    components: [...],
    instances: [...]
  }
}
```
