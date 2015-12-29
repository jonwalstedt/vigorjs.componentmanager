var componentSettings = {
  components: [{
    id: 'hello-world-component',
    src: 'ExampleComponent' // ExampleComponent.js in the examples directory - exposed on window
  }],
  targets: {
    main: [
      {
        id: 'hello-world-instance',
        componentId: 'hello-world-component',
        urlPattern: 'add-hello-world', // #add-hello-world
        args: {
          id: 'hello-world-instance',
          urlPattern: 'add-hello-world',
          background: '#F6FFBA'
        }
      }
    ]
  }
}
