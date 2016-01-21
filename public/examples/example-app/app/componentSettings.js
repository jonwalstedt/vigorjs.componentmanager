define(function (require) {
  'use strict';
  var componentSettings,
    subscriptionKeys = require('SubscriptionKeys');

  componentSettings = {
    components: [
      {
        id: 'linechart-component',
        src: 'components/chart',
        args: {
          type: 'line-chart'
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
        {
          id: 'linechart',
          componentId: 'linechart-component',
          urlPattern: '',
          args: {
            title: 'MB uploaded per month',
            colors: ['#fff4f3', '#7C87FA', '#61d6eb', '#5DFFBE'],
            subscriptionKey: subscriptionKeys.DAILY_USAGE
          }
        },
        {
          id: 'movie-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Videos',
            colors: ['#f7998e', '#fff4f3', '#7C87FA'],
            subscriptionKey: subscriptionKeys.VIDEO_QUOTA
          }
        },
        {
          id: 'photos-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Photos',
            colors: ['#f7998e', '#fff4f3', '#61d6eb'],
            subscriptionKey: subscriptionKeys.PHOTO_QUOTA
          }
        },
        {
          id: 'music-quota-circular-chart',
          componentId: 'circularchart-component',
          urlPattern: '',
          args: {
            title: 'Music',
            colors: ['#f7998e', '#fff4f3', '#5DFFBE'],
            subscriptionKey: subscriptionKeys.MUSIC_QUOTA
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