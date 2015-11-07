```javascript
var componentSettings = {
  components: [{
    id: 'filter-condition-component',
    src: 'ExampleComponent' // ExampleComponent.js in the examples directory - exposed on window
  }],

  targets: {
    main: [
      {
        id: 'filter-instance-1',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        args: {
          title: 'id: filter-instance-1',
          urlPattern: 'foo/:bar',
          background: '#9FEDFF'
        }
      },

      {
        id: 'filter-instance-2',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        args: {
          title: 'id: filter-instance-2',
          urlPattern: 'foo/:bar',
          background: '#9FEDFF'
        }
      },

      {
        id: 'filter-instance-3',
        componentId: 'filter-condition-component',
        urlPattern: 'foo/:bar',
        args: {
          title: 'id: filter-instance-3',
          urlPattern: 'foo/:bar',
          background: '#9FEDFF'
        }
      },

      {
        id: 'filter-instance-4',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        args: {
          title: 'id: filter-instance-4',
          urlPattern: 'bar/:baz',
          background: '#9F9EE8'
        }
      },

      {
        id: 'filter-instance-5',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        args: {
          title: 'id: filter-instance-5',
          urlPattern: 'bar/:baz',
          background: '#9F9EE8'
        }
      },

      {
        id: 'filter-instance-6',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        args: {
          title: 'id: filter-instance-6',
          urlPattern: 'bar/:baz',
          background: '#9F9EE8'
        }
      },

      {
        id: 'filter-instance-7',
        componentId: 'filter-condition-component',
        urlPattern: 'bar/:baz',
        filterString: 'bar',
        args: {
          title: "id: filter-instance-7",
          urlPattern: 'bar/:baz',
          background: '#0F9EF8',
          filterString: 'bar'
        }
      }
    ]
  }
}

```
