var componentSettings = {
  components: [
    {
      id: 'barchart-component',
      src: 'app.components.Chart',
      args: {
        type: 'bar-chart'
      }
    },
    {
      id: 'linechart-component',
      src: 'app.components.Chart',
      args: {
        type: 'line-chart'
      }
    },
    {
      id: 'doughnutchart-component',
      src: 'app.components.Chart',
      args: {
        type: 'doughnut-chart'
      }
    },
    {
      id: 'menu-component',
      src: 'app.components.Menu'
    },
    {
      id: 'header-component',
      src: 'app.components.Header'
    },
    {
      id: 'list-component',
      src: 'app.components.List'
    },
    {
      id: 'banner-component',
      src: 'app.components.BannerComponent'
    }

  ],

  targets: {
    "list-pos3": [
     {
        id: 'banner-1',
        componentId: 'banner-component',
        src: "app.components.ExtendedIframeComponent",
        args: {
          iframeAttributes:{
            src: 'http://localhost:3000/examples/example-app/example-banners/banner-one/index.html?id=banner-1',
            width: '100%',
            height: 180
          }
        }
      }
    ],
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
        id: 'barchart',
        componentId: 'barchart-component',
        order: 2,
        urlPattern: ''
      },
      {
        id: 'doughnutchart',
        componentId: 'doughnutchart-component',
        order: 3,
        urlPattern: ''
      },
      {
        id: 'projects-list',
        componentId: 'list-component',
        order: 1,
        args: {
          subscriptionKey: Vigor.SubscriptionKeys.PROJECTS
        },
        urlPattern: 'projects'
      },
      // {
      //   id: 'order-instance-4',
      //   componentId: 'barchart-component',
      //   order: 4,
      //   urlPattern: 'link_one/:depth1'
      // },
      // {
      //   id: 'order-instance-5',
      //   componentId: 'barchart-component',
      //   order: 5,
      //   urlPattern: 'link_one/:depth1'
      // }
    ]
  }
}
