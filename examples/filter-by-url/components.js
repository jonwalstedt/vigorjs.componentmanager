var componentSettings = {
  "conditions": {},
  "components": [{
    "id": "filter-url",
    "src": "app.components.FilterComponent"
  }],
  "hidden": [],
  "targets": {
    "main": [
      {
        "id": "filter-url-instance-1",
        "componentId": "filter-url",
        "args": {
          "title": "id: 1",
          "urlPattern": "passing-arguments/:type/:id"
        },
        "urlPattern": "passing-arguments/:type/:id"
      },

      {
        "id": "filter-url-instance-2",
        "componentId": "filter-url",
        "args": {
          "title": "id: 2",
          "urlPattern": "passing-arguments/:type/:id"
        },
        "urlPattern": "passing-arguments/:type/:id",
        "reInstantiateOnUrlParamChange": true
      },

      {
        "id": "filter-url-instance-3",
        "componentId": "filter-url",
        "args": {
          "title": "id: 3",
          "urlPattern": "splat/*path"
        },
        "urlPattern": "splat/*path"
      },

      {
        "id": "filter-url-instance-4",
        "componentId": "filter-url",
        "args": {
          "title": "id: 4",
          "urlPattern": "optional/:section(/:subsection)"
        },
        "urlPattern": "optional/:section(/:subsection)"
      },

      {
        "id": "filter-url-instance-5",
        "componentId": "filter-url",
        "args": {
          "title": "id: 5",
          "urlPattern": "global"
        },
        "urlPattern": "global"
      }

    ]
  }
}
