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
      }
    ]
  }
}
