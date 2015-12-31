```javascript
var componentSettings = {
  components: [{
    id: 'filter-url-component',
    src: 'ExampleComponent'
  }],
  targets: {
    main: [
      {
        id: 'filter-url-instance-1',
        componentId: 'filter-url-component',
        order: 1,
        args: {
          id: 'id: 1',
          urlPattern: 'passing-arguments/:type/:id',
          background: 'coral'
        },
        urlPattern: 'passing-arguments/:type/:id'
      },
      {
        id: 'filter-url-instance-2',
        componentId: 'filter-url-component',
        order: 2,
        args: {
          id: 'id: 2',
          urlPattern: 'passing-arguments/:type/:id',
          background: 'pink'
        },
        urlPattern: 'passing-arguments/:type/:id',
        reInstantiate: true
      },
      {
        id: 'filter-url-instance-3',
        componentId: 'filter-url-component',
        order: 3,
        args: {
          id: 'id: 3',
          urlPattern: 'splat/*path',
          background: 'yellow'
        },
        urlPattern: 'splat/*path'
      },
      {
        id: 'filter-url-instance-4',
        componentId: 'filter-url-component',
        order: 4,
        args: {
          id: 'id: 4',
          urlPattern: 'optional/:section(/:subsection)',
          background: 'Aquamarine '
        },
        urlPattern: 'optional/:section(/:subsection)'
      },
      {
        id: 'filter-url-instance-5',
        componentId: 'filter-url-component',
        order: 5,
        args: {
          id: 'id: 5',
          urlPattern: 'optional/:section(/:subsection)(/:id)',
          background: 'silver'
        },
        urlPattern: 'optional/:section(/:subsection)(/:id)'
      },
      {
        id: 'filter-url-instance-6',
        componentId: 'filter-url-component',
        order: 6,
        args: {
          id: 'id: 6',
          urlPattern: 'global',
          background: 'aqua'
        },
        urlPattern: 'global'
      },
      {
        id: 'filter-url-instance-7',
        componentId: 'filter-url-component',
        order: 7,
        args: {
          id: 'id: 7',
          urlPattern: '["some-url/:id", "some-other-url(/:year)(/:month)(/:day)"]',
          background: '#58EBA9'
        },
        urlPattern: ['some-url/:id', 'some-other-url(/:year)(/:month)(/:day)']
      }
    ]
  }
}
```
