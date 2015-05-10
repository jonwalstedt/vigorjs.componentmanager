var componentSettings = {
  "conditions": {},
  "components": [{
    "id": "filter-string",
    "src": "app.components.FilterComponent"
  }],
  "hidden": [],
  "targets": {
    "main": [
      {
        "id": "filter-string-instance",
        "componentId": "filter-string",
        "args": {
          "title": "id: 1",
          "filterString": "This instance does not have a filterString (it will be undefined)"
        },
        "urlPattern": "global"
      },

      {
        "id": "filter-string-second-instance",
        "componentId": "filter-string",
        "args": {
          "title": "id: 2",
          "filterString": "lorem/ipsum/test"
        },
        "urlPattern": "global",
        "filterString": "lorem/ipsum/test"
      },

      {
        "id": "filter-string-third-instance",
        "componentId": "filter-string",
        "args": {
          "title": "id: 3",
          "filterString": "a filter string could be any string"
        },
        "urlPattern": "global",
        "filterString": "a filter string could be any string"
      }
    ]
  }
}
