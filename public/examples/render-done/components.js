var componentSettings = {
  components: [
    {
      id: 'barchart-component',
      src: 'app.components.BarChartComponent'
    },
    {
      id: 'linechart-component',
      src: 'app.components.LineChartComponent'
    },
    {
      id: 'menu-component',
      src: 'app.components.MenuComponent'
    },
    {
      id: 'header-component',
      src: 'app.components.HeaderComponent'
    }
  ],

  targets: {
    header: [
      {
        id: 'header',
        componentId: 'header-component',
        urlPattern: 'global'
      }
    ],
    menu: [
      {
        id: 'menu',
        componentId: 'menu-component',
        urlPattern: 'global'
      }
    ],
    main: [
      {
        id: 'linechart',
        componentId: 'linechart-component',
        order: 1,
        urlPattern: ''
      },
      {
        id: 'barchart-1',
        componentId: 'barchart-component',
        order: 2,
        urlPattern: ''
      },
      {
        id: 'barchart-2',
        componentId: 'barchart-component',
        order: 3,
        urlPattern: ''
      },
      {
        id: 'order-instance-4',
        componentId: 'barchart-component',
        order: 4,
        urlPattern: 'link_one/:depth1'
      },
      {
        id: 'order-instance-5',
        componentId: 'barchart-component',
        order: 5,
        urlPattern: 'link_one/:depth1'
      }
    ]
  }
}
