var componentSettings = {
  components: [{
    id: "filter-string-component",
    src: "app.components.FilterComponent"
  }],
  targets: {
    main: [
      {
        id: "filter-string-instance-1",
        componentId: "filter-string-component",
        args: {
          title: "id: 1",
          filterString: "This instance does not have a filterString (it will be undefined)"
        }
      },

      {
        id: "filter-string-instance-2",
        componentId: "filter-string-component",
        args: {
          title: "id: 2",
          filterString: "lorem/ipsum/test"
        },
        filterString: "lorem/ipsum/test"
      },

      {
        id: "filter-string-instance-3",
        componentId: "filter-string-component",
        args: {
          title: "id: 3",
          filterString: "a filter string could be any string"
        },
        filterString: "a filter string could be any string"
      },

      {
        id: "filter-string-instance-4",
        componentId: "filter-string-component",
        args: {
          title: "id: 4",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method"
        },
        filterStringHasToMatch: "test1"
      },

      {
        id: "filter-string-instance-5",
        componentId: "filter-string-component",
        args: {
          title: "id: 5",
          filterString: "undefined - the filterString is set on the filter passed to the refresh method"
        },
        filterStringCantMatch: "test1"
      }
    ]
  }
}
