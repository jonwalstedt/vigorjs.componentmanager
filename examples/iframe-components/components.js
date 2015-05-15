var componentSettings = {
  "conditions": {},

  "components": [{
    "id": "filter-instance",
    "src": "http://en.wikipedia.org/wiki/Main_Page"
  }],

  "hidden": [],

  "targets": {
    "main": [
      {
        "id": "filter-instance",
        "componentId": "filter-instance",
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
