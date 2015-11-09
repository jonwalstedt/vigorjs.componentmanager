```javascript
var componentSettings = {
  components: [
    {
      id: 'filter-condition-component',
      src: 'ExampleComponent' // ExampleComponent.js in the examples directory - exposed on window
    },
    {
      id: 'filter-condition-component2',
      src: 'ExampleComponent', // ExampleComponent.js in the examples directory - exposed on window
      type: 'yellow-component',
      componentStyle: 'custom'
    }
  ],

  targets: {
    main: [
      {
        id: 'filter-instance-1',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        type: 'grey-component',
        args: {
          title: 'id: filter-instance-1',
          urlPattern: 'foo/:bar',
          type: 'grey-component',
          background: 'grey'
        }
      },

      {
        id: 'filter-instance-2',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        type: 'grey-component',
        args: {
          title: 'id: filter-instance-2',
          urlPattern: 'foo/:bar',
          type: 'grey-component',
          background: 'grey'
        }
      },

      {
        id: 'filter-instance-3',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        type: 'green-component',
        args: {
          title: 'id: filter-instance-3',
          urlPattern: 'foo/:bar',
          type: 'green-component',
          background: 'green'
        }
      },

      {
        id: 'filter-instance-4',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        type: 'green-component',
        args: {
          title: 'id: filter-instance-4',
          urlPattern: 'bar/:baz',
          type: 'green-component',
          background: 'green'
        }
      },

      {
        id: 'filter-instance-5',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        type: 'red-component',
        args: {
          title: 'id: filter-instance-5',
          urlPattern: 'bar/:baz',
          type: 'red-component',
          background: 'red'
        }
      },

      {
        id: 'filter-instance-6',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        type: 'red-component',
        args: {
          title: 'id: filter-instance-6',
          urlPattern: 'bar/:baz',
          type: 'red-component',
          background: 'red'
        }
      },

      {
        id: 'filter-instance-7',
        componentId: 'filter-condition-component2',
        urlPattern: 'bar/:baz',
        type: 'red-component',
        args: {
          title: 'id: filter-instance-7',
          urlPattern: 'bar/:baz',
          type: 'red-component',
          background: 'red'
        }
      },

      {
        id: 'filter-instance-8',
        componentId: 'filter-condition-component2',
        urlPattern: 'foo/:bar',
        args: {
          title: 'id: filter-instance-8',
          urlPattern: 'bar/:baz',
          background: 'yellow'
        }
      }
    ]
  }
}

```
