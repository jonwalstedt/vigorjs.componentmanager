var componentSettings = {
  "conditions": {},
  "components": [{
    "id": "hello-world",
    "src": "app.components.HelloWorldComponent"
  }],
  "hidden": [],
  "targets": {
    "main": [
      {
        "id": "hello-world-instance",
        "componentId": "hello-world",
        "urlPattern": "add-hello-world", // #add-hello-world
        "filter": "test"
      }
    ]
  }
}
