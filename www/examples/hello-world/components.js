var componentSettings = {
  components: [{
    id: 'hello-world-component',
    src: 'ExampleComponent', // ExampleComponent.js in the examples directory - exposed on window

    // specify fields types with defaults here ex (support both scenarios below):
    vcmArgumentFields: [
      {
        id: 'my-text-field',
        type: 'text-field',
        label: 'Pretty label',
        default: 'Hello World'
      },
      {
        id: 'my-number-field',
        type: 'number-field',
        label: 'Pretty label',
        default: 4
      },
      {
        id: 'my-checkbox',
        type: 'checkbox',
        label: 'Is On',
        default: false,
        checked: true
      },
      {
        id: 'my-select-menu',
        type: 'select',
        label: 'My select menu',
        default: 2,
        options: [
          {
            label: 'Option 1',
            value: 1
          },
          {
            label: 'Option 2',
            value: 2,
          },
          {
            label: 'Option 3',
            value: 3,
          }
        ]
      }
    ]
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
