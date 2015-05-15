var componentSettings = {
  "conditions": {},

  "components": [
    {
      "id": "iframe-component",
      "src": "http://en.wikipedia.org/wiki/Main_Page"
    },
    {
      "id": "extended-iframe-component",
      "src": "app.components.ExtendedIframeComponent",
      "args": {
        "iframeAttributes":{
          "src": "http://en.wikipedia.org/wiki/Main_Page"
        }
      }
    }
  ],

  "hidden": [],

  "targets": {
    "first": [
      {
        "id": "iframe-instance",
        "componentId": "iframe-component",
        "args": {
          "iframeAttributes": {
            "width": 600,
            "height": 400
          }
        },
        "urlPattern": "global"
      }
    ],
    "second": [
      {
        "id": "iframe-instance-2",
        "componentId": "extended-iframe-component",
        "args": {
          "iframeAttributes": {
            "width": 600,
            "height": 400
          }
        },
        "urlPattern": "global"
      }
    ]
  }
}
