var componentSettings = {
  "conditions": {},

  "components": [{
    "id": "order-component",
    "src": "app.components.FilterComponent"
  }],

  "hidden": [],

  "targets": {
    "main": [
      {
        "id": "order-instance-1",
        "componentId": "order-component",
        "order": 1,
        "args": {
          "title": "1",
          "background": "aqua"
        },
        "urlPattern": "global"
      },
      {
        "id": "order-instance-2",
        "componentId": "order-component",
        "order": 2,
        "args": {
          "title": "2",
          "background": "green"
        },
        "urlPattern": "global"
      },
      {
        "id": "order-instance-3",
        "componentId": "order-component",
        "order": 3,
        "args": {
          "title": "3",
          "background": "silver"
        },
        "urlPattern": "global"
      },
      {
        "id": "order-instance-4",
        "componentId": "order-component",
        "order": 4,
        "args": {
          "title": "4",
          "background": "yellow"
        },
        "urlPattern": "global"
      },
      {
        "id": "order-instance-5",
        "componentId": "order-component",
        "order": 5,
        "args": {
          "title": "5",
          "background": "pink"
        },
        "urlPattern": "global"
      }
    ]
  }
}
