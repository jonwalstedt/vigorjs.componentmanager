var componentSettings = {
  "components": [
    {
      "componentId": 'app-component-one',
      "src": "app.ComponentOne",
      "showcount": 2
    }
  ],

  "hidden": [],

  "targets": {
    "home": [
      {
        "order": "top",
        "componentId": "app-component-one",
        "urlPattern": "route1/:id",
        "args": { test: [], testTwo: {}}
      },
      {
        "order": 10,
        "componentId": "app-component-two"
      }
    ],
    "header": [
      {"order": 10, "componentId": "app-component-three"}
    ]
  }
}