var componentSettings = {
  components: [{
    id: "order-component",
    src: "app.components.DashboardComponent"
  }],

  targets: {
    main: [
      {
        id: "order-instance-1",
        componentId: "order-component",
        order: 1,
        args: {
          order: "1",
          background: "#B4EFFF",
          url: '#stats'
        },
        urlPattern: "test2"
      },
      {
        id: "order-instance-2",
        componentId: "order-component",
        order: 2,
        args: {
          order: "2",
          background: "#67DEFF"
        },
        urlPattern: "test"
      },
      {
        id: "order-instance-3",
        componentId: "order-component",
        order: 3,
        args: {
          order: "3",
          background: "#90BFCC"
        },
        urlPattern: "test"
      },
      {
        id: "order-instance-4",
        componentId: "order-component",
        order: 4,
        args: {
          order: "4",
          background: "#5A777F"
        },
        urlPattern: "test"
      },
      {
        id: "order-instance-5",
        componentId: "order-component",
        order: 5,
        args: {
          order: "5",
          background: "#346F7F"
        },
        urlPattern: "test"
      }
    ]
  }
}
