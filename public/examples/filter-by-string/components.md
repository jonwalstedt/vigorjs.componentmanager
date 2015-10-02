```javascript
var componentSettings = {
  components: [{
    id: "filter-string-component",
    src: "ExampleComponent" // ExampleComponent.js in the examples directory - exposed on window
  }],
  targets: {
    "first-examples": [
      {
        id: "filter-string-instance-1",
        componentId: "filter-string-component",
        order: 1,
        args: {
          title: "id: 1",
          filterString: "undefined",
          background: "#F6FFBA"
        }
      },

      {
        id: "filter-string-instance-2",
        componentId: "filter-string-component",
        order: 2,
        args: {
          title: "id: 2",
          filterString: "lorem/ipsum/<b>first</b>",
          background: "#B7E8D4"
        },
        filterString: "first"
      },

      {
        id: "filter-string-instance-3",
        componentId: "filter-string-component",
        order: 3,
        args: {
          title: "id: 3",
          filterString: "a filter string could be any string",
          background: "#B6C4FF"
        },
        filterString: "a filter string could be any string"
      },
    ],
    "second-examples": [
      {
        id: "filter-string-instance-4",
        componentId: "filter-string-component",
        order: 4,
        args: {
          title: "id: 4",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "'state=one'",
          background: "#9FEDFF"
        },
        includeIfFilterStringMatches: "state=one"
      },

      {
        id: "filter-string-instance-5",
        componentId: "filter-string-component",
        order: 5,
        args: {
          title: "id: 5",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "'state=one'",
          excludeIfFilterStringMatches: "'lang=en_GB'",
          background: "#9F9EE8"
        },
        includeIfFilterStringMatches: "state=one",
        excludeIfFilterStringMatches: "lang=en_GB"
      },

      {
        id: "filter-string-instance-6",
        componentId: "filter-string-component",
        order: 6,
        args: {
          title: "id: 6",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "'lang=en_GB'",
          background: "#F9D1FF"
        },
        includeIfFilterStringMatches: "lang=en_GB"
      },

      {
        id: "filter-string-instance-7",
        componentId: "filter-string-component",
        order: 7,
        args: {
          title: "id: 7",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "/[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/",
          background: "#E8CECB"
        },
        includeIfFilterStringMatches: /[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/
      }
    ]
  }
}
```
