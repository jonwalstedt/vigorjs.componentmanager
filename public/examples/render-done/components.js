var componentSettings = {
  components: [
    {
      id: "dashboard-component",
      src: "app.components.DashboardComponent"
    },
    {
      id: "menu-component",
      src: "app.components.MenuComponent"
    }
  ],

  targets: {
    menu: [
      {
        id: "menu",
        componentId: "menu-component",
        urlPattern: 'global'
      }
    ],
    depth1: [
      {
        id: "order-instance-1",
        componentId: "dashboard-component",
        order: 1,
        urlPattern: "home"
      },
      {
        id: "order-instance-2",
        componentId: "dashboard-component",
        order: 2,
        urlPattern: "home"
      },
      {
        id: "order-instance-3",
        componentId: "dashboard-component",
        order: 3,
        urlPattern: "home"
      },
      {
        id: "order-instance-4",
        componentId: "dashboard-component",
        order: 4,
        urlPattern: "home"
      },
      {
        id: "order-instance-5",
        componentId: "dashboard-component",
        order: 5,
        urlPattern: "home"
      }
    ]
  }
}
