var componentSettings = {
  "conditions": {
    withinTimeSpan: function () {
      var today = new Date().getHours(),
          startTime = 18,
          endTime = 24,
          allowed = (today >= startTime && today <= endTime);
      console.log('is within timespan: ', allowed);
      return allowed;
    }
  },

  "components": [{
    "id": "filter-instance",
    "src": "app.components.FilterComponent",
    "conditions": ["withinTimeSpan"]
  }],

  "hidden": [],

  "targets": {
    "main": [
      {
        "id": "filter-instance-1",
        "componentId": "filter-instance",
        "args": {
          "title": "id: filter-instance-1",
          "background": "red"
        }
      },

      {
        "id": "filter-instance-2",
        "componentId": "filter-instance",
        "args": {
          "title": "id: filter-instance-2",
          "background": "silver"
        }
      }
    ]
  }
}
