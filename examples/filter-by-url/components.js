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
          "urlPattern": "passing-arguments/:type/:id",
          "background": "red"
        },
        "urlPattern": "passing-arguments/:type/:id"
      },

      {
        "id": "filter-url-instance-2",
        "componentId": "filter-url",
        "args": {
          "title": "id: 2",
          "urlPattern": "passing-arguments/:type/:id",
          "background": "blue"
        },
        "urlPattern": "passing-arguments/:type/:id",
        "reInstantiateOnUrlParamChange": true
      },

      {
        "id": "filter-url-instance-3",
        "componentId": "filter-url",
        "args": {
          "title": "id: 3",
          "urlPattern": "splat/*path",
          "background": "yellow"
        },
        "urlPattern": "splat/*path"
      },

      {
        "id": "filter-url-instance-4",
        "componentId": "filter-url",
        "args": {
          "title": "id: 4",
          "urlPattern": "optional/:section(/:subsection)",
          "background": "green"
        },
        "urlPattern": "optional/:section(/:subsection)"
      },

      {
        "id": "filter-url-instance-5",
        "componentId": "filter-url",
        "args": {
          "title": "id: 5",
          "urlPattern": "optional/:section(/:subsection)(/:id)",
          "background": "silver"
        },
        "urlPattern": "optional/:section(/:subsection)(/:id)"
      },

      {
        "id": "filter-url-instance-6",
        "componentId": "filter-url",
        "args": {
          "title": "id: 6",
          "urlPattern": "global",
          "background": "aqua"
        },
        "urlPattern": "global"
      }

    ]
  }
}
