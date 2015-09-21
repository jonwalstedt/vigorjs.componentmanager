var componentSettings = {
  components: [{
    id: "hello-world-component",
    src: "app.components.HelloWorldComponent"
  }],
  targets: {
    main: [
      {
        id: "hello-world-instance",
        componentId: "hello-world-component",
        urlPattern: "add-hello-world" // #add-hello-world
      }
    ]
  }
}
