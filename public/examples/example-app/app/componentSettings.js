define(function (require) {
  'use strict';
  var componentSettings,
    subscriptionKeys = require('SubscriptionKeys');

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
        id: 'circularchart-component',
        src: 'components/circular-chart'
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
        id: 'mini-profile-component',
        src: 'components/mini-profile'
      },
      // {
      //   id: 'list-component',
      //   src: 'components/list'
      // },
      {
        id: 'banner-component',
        src: 'components/banner'
      },

    ],

    targets: {
      "list-pos3": [
       // {
       //    id: 'banner-1',
       //    componentId: 'banner-component',
       //    src: "components/ExtendedIframeComponent",
       //    args: {
       //      iframeAttributes:{
       //        src: 'http://localhost:3000/examples/example-app/example-banners/banner-one/index.html?id=banner-1',
       //        width: '100%',
       //        height: 180
       //      }
       //    }
       //  }
      ],
      header: [
        // {
        //   id: 'header',
        //   componentId: 'header-component',
        //   urlPattern: 'global'
        // }
      ],
      sidebar: [
        {
          id: 'mini-profile',
          componentId: 'mini-profile-component',
          urlPattern: 'global'
        },
        {
          id: 'menu',
          componentId: 'menu-component',
          urlPattern: 'global'
        }
      ],
      main: [
        // {
        //   id: 'linechart',
        //   componentId: 'linechart-component',
        //   urlPattern: ''
        // },
        // {
        //   id: 'barchart',
        //   componentId: 'barchart-component',
        //   urlPattern: ''
        // },
        // {
        //   id: 'doughnutchart',
        //   componentId: 'doughnutchart-component',
        //   urlPattern: '',
        //   args: {
        //     subscriptionKey: subscriptionKeys.MUSIC_QUOTA,
        //   }
        // },

        {
          id: 'movie-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Movies',
            subscriptionKey: subscriptionKeys.MUSIC_QUOTA,
          }
        },
        {
          id: 'photos-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Photos',
            subscriptionKey: subscriptionKeys.MUSIC_QUOTA,
          }
        },
        {
          id: 'music-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Music',
            subscriptionKey: subscriptionKeys.MUSIC_QUOTA,
          }
        },
        // {
        //   id: 'article-list',
        //   componentId: 'list-component',
        //   args: {
        //     subscriptionKey: subscriptionKeys.ARTICLES
        //   },
        //   urlPattern: 'filter',
        //   reInstantiate: true
        // },
        // {
        //   id: 'projects-list',
        //   componentId: 'list-component',
        //   args: {
        //     subscriptionKey: subscriptionKeys.ARTICLES
        //   },
        //   urlPattern: 'projects'
        // },
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