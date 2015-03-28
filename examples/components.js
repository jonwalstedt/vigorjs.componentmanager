var componentSettings = {
  "components": [
    {
      "componentId": 'app-component-one',
      "src": "app-component-one",
      "showcount": 2
    }
  ],

  "hidden": [],

  "targets": {
    "home": [
      {"order": "top", "componentId": "app-component-one"},
      {"order": 10, "componentId": "app-component-two"}
    ],
    "header": [
      {"order": 10, "componentId": "app-component-three"}
    ]
  }
}