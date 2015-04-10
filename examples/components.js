var componentSettings = {
  "components": [
    {
      "componentId": 'app-component-one',
      "src": "app.ComponentOne",
      "maxShowCount": 2
    },
    {
      "componentId": 'app-component-two',
      "src": "app.ComponentTwo"
    },
    {
      "componentId": 'app-component-three',
      "src": "app.ComponentThree"
    }
  ],

  "hidden": [],

  "targets": {
    "main": [
      {
        "order": "top",
        "componentId": "app-component-one",
        "urlPattern": "route1/:id",
        "args": { test: [], testTwo: {}}
      },
      {
        "order": 10,
        "componentId": "app-component-two",
        "urlPattern": "route2/:id"
      },
      {
        "order": 20,
        "componentId": "app-component-two",
        "urlPattern": "route2/:id"
      },
      {
        "order": 9,
        "componentId": "app-component-three",
        "urlPattern": "route2/:id"
      },
      {
        "order": 50,
        "componentId": "app-component-three",
        "urlPattern": "route2/:id"
      }
    ],
    "sidebar-first": [
      {
        "componentId": "app-component-three",
        "urlPattern": "route2/:id"
      }
    ],
    "sidebar-second": [
      {
        "componentId": "app-component-three",
        "urlPattern": "route3/:id"
      }
    ]
  }
}