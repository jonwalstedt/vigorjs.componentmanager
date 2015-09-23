var componentSettings = {
  components: [{
    id: "filter-string-component",
    src: "app.components.FilterComponent"
  }],
  targets: {
    first: [
      {
        id: "filter-string-instance-1",
        componentId: "filter-string-component",
        order: 1,
        args: {
          title: "id: 1",
          filterString: "undefined"
        }
      },

      {
        id: "filter-string-instance-2",
        componentId: "filter-string-component",
        order: 2,
        args: {
          title: "id: 2",
          filterString: "lorem/ipsum/<b>first</b>"
        },
        filterString: "first"
      },

      {
        id: "filter-string-instance-3",
        componentId: "filter-string-component",
        order: 3,
        args: {
          title: "id: 3",
          filterString: "a filter string could be any string"
        },
        filterString: "a filter string could be any string"
      },
    ],
    second: [
      {
        id: "filter-string-instance-4",
        componentId: "filter-string-component",
        order: 4,
        args: {
          title: "id: 4",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "includeIfFilterStringMatches = 'state=one'",
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
          includeIfFilterStringMatches: "includeIfFilterStringMatches = 'state=one'",
          excludeIfFilterStringMatches: "excludeIfFilterStringMatches = 'lang=en_GB'",
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
          includeIfFilterStringMatches: "includeIfFilterStringMatches = 'lang=en_GB'",
        },
        includeIfFilterStringMatches: "lang=en_GB"
      },

      {
        id: "filter-string-instance-8",
        componentId: "filter-string-component",
        order: 8,
        args: {
          title: "id: 8",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method",
          includeIfFilterStringMatches: "includeIfFilterStringMatches = /[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/",
        },
        includeIfFilterStringMatches: /[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/
      }
    ]
  }
}

