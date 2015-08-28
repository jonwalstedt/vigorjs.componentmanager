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
    },
    {
      "id": "extended-iframe-component-that-sends-message",
      "src": "app.components.ExtendedIframeComponentThatSendsMessage"
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
    ],
    "third": [
      {
        "id": "iframe-instance-3",
        "componentId": "extended-iframe-component-that-sends-message",
        "args": {
          "iframeAttributes": {
            "width": 600,
            "height": 400,
            "style": "border: 1px solid red",
            "src": "http://localhost:7070/examples/iframe-components/iframed-example-page.html?id=iframe-instance-3"
          }
        },
        "urlPattern": "global"
      },
      {
        "id": "iframe-instance-4",
        "componentId": "extended-iframe-component-that-sends-message",
        "args": {
          "iframeAttributes": {
            "width": 600,
            "height": 400,
            "style": "border: 1px solid blue",
            "src": "http://localhost:7070/examples/iframe-components/iframed-example-page.html?id=iframe-instance-4"
          }
        },
        "urlPattern": "global"
      }
    ]

  }
}
