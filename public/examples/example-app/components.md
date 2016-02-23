```javascript
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
        id: 'mini-profile-component',
        src: 'components/mini-profile'
      },
      {
        id: 'file-list-component',
        src: 'components/file-list'
      },
      {
        id: 'media-player-component',
        src: 'components/media-player'
      }
    ],

    targets: {
      header: [],
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
        {
          id: 'file-list',
          componentId: 'file-list-component',
          urlPattern: 'files(/:filetype)(/:page)'
        },
        {
          id: 'media-player',
          componentId: 'media-player-component',
          urlPattern: 'file/:filetype/:id'
        }
      ]
    }
  }
  return componentSettings;
});```
