define(function (require) {
  'use strict';
  var componentSettings,
    SubscriptionKeys = require('SubscriptionKeys');

  componentSettings = {
    components: [
      {
        id: 'barchart-component',
        src: 'components/chart',
        args: {
          type: 'bar-chart'
        }
      },
      {
        id: 'linechart-component',
        src: 'components/chart',
        args: {
          type: 'line-chart'
        }
      },
      {
        id: 'doughnutchart-component',
        src: 'components/chart',
        args: {
          type: 'doughnut-chart'
        }
      },
      {
        id: 'menu-component',
        src: 'components/menu'
      },
      {
        id: 'header-component',
        src: 'components/header'
      },
      {
        id: 'list-component',
        src: 'components/list'
      },
      {
        id: 'banner-component',
        src: 'components/banner'
      }

    ],

    targets: {
      "list-pos3": [
       {
          id: 'banner-1',
          componentId: 'banner-component',
          src: "components/ExtendedIframeComponent",
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
            subscriptionKey: SubscriptionKeys.PROJECTS
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
  return componentSettings;
});