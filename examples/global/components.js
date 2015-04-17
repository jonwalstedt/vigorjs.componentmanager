var componentSettings = {
  "components": [
    {
      "componentId": 'app-navigation',
      "src": "app.components.NavigationComponent"
    },
    {
      "componentId": 'app-login',
      "src": "app.components.LoginComponent"
    },
    {
      "componentId": 'app-marquee',
      "src": "app.components.MarqueeComponent"
    },
    {
      "componentId": 'app-profile-overview',
      "src": "app.components.ProfileOverViewComponent"
    },
    {
      "componentId": 'app-social-media',
      "src": "app.components.SocialMediaComponent"
    },
    {
      "componentId": 'app-list',
      "src": "app.components.ListComponent"
    }
  ],

  "hidden": [],

  "targets": {
    "header": [
      {
        "id": "navigation",
        "componentId": "app-navigation",
        "urlPattern": "global",
        "conditions": "authenticated"
      }
    ],

    "main": [
      {
        "id": "app-login",
        "componentId": "app-login",
        "urlPattern": ["", "landing", "logout"]
      },
      {
        "id": "app-list",
        "componentId": "app-list",
        "urlPattern": ["home", "event/*path"]
      }
    ],
   "below-header": [
      {
        "id": "app-marquee",
        "componentId": "app-marquee",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "sidebar-top": [
      {
        "id": "app-profile-overview",
        "componentId": "app-profile-overview",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "sidebar-bottom": [
      {
        "id": "app-social-media",
        "componentId": "app-social-media",
        "urlPattern": ["home", "event/*path"]
      }
   ],
   "right-column": [
      {
        "id": "app-list-two",
        "componentId": "app-list",
        "urlPattern": "event/:id",
        "reInstantiateOnUrlParamChange": true
      }
   ]
  }
}
      // {
      //   "id": "comp1",
      //   "order": 0,
      //   "componentId": "app-component-one",
      //   "urlPattern": "global",
      //   "args": { title: "Im global", text: "and some text"},
      //   "filter": '(England)'
      // },
      // {
      //   "id": "comp21",
      //   "order": "top",
      //   "componentId": "app-component-four",
      //   "urlPattern": ["route1/:id", "route2/:id"],
      //   "args": { test: [], testTwo: {}}
      //   // "filter": 'testfilter2'
      // },

      // {
      //   "id": "comp2",
      //   "order": 10,
      //   "componentId": "app-component-two",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp3",
      //   "order": 20,
      //   "componentId": "app-component-two",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp4",
      //   "order": 9,
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp5",
      //   "order": 50,
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // }
