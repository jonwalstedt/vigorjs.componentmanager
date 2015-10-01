var componentSettings = {

  components: [{
    id: "order-component",
    src: "app.components.FilterComponent"
  }],

  targets: {
    main: [
      {
        id: "order-instance-1",
        componentId: "order-component",
        order: 1,
        args: {
          order: "1",
          background: "#D5FFE9"
        }
      },
      {
        id: "order-instance-2",
        componentId: "order-component",
        order: 2,
        args: {
          order: "2",
          background: "#88FFC2"
        }
      },
      {
        id: "order-instance-3",
        componentId: "order-component",
        order: 3,
        args: {
          order: "3",
          background: "#AACCBB"
        }
      },
      {
        id: "order-instance-4",
        componentId: "order-component",
        order: 4,
        args: {
          order: "4",
          background: "#6A7F75"
        }
      },
      {
        id: "order-instance-5",
        componentId: "order-component",
        order: 5,
        args: {
          order: "5",
          background: "#447F61"
        }
      }
    ]
  }
}
