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
      "componentId": 'app-component-four',
      "src": "http://www.wikipedia.com"
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
    ],
   "below-header": [
      {
        "id": "app-marquee",
        "componentId": "app-marquee",
        "urlPattern": "home"
      }
   ]
  }
}