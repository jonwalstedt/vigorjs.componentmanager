var componentSettings = {
  "components": [
    {
      "componentId": 'app-component-one',
      "src": "app.ComponentOne",
      "maxShowCount": 2
    },
    {
      "componentId": 'app-component-two',
      "src": "app.ComponentTwo"
    },
    {
      "componentId": 'app-component-three',
      "src": "app.ComponentThree"
    },
    {
      "componentId": 'app-component-four',
      "src": "http://www.wikipedia.com"
    }
  ],

  "hidden": [],

  "targets": {
    "main": [
      {
        "id": "comp1",
        "order": "top",
        "componentId": "app-component-one",
        "urlPattern": "global",
        "args": { title: "Im global", text: "and some text"},
        "filter": '(England)'
      },
      {
        "id": "comp21",
        "order": "top",
        "componentId": "app-component-four",
        "urlPattern": ["route1/:id", "route2/:id"],
        "args": { test: [], testTwo: {}}
        // "filter": 'testfilter2'
      },

      // {
      //   "id": "comp2",
      //   "order": 10,
      //   "componentId": "app-component-two",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp3",
      //   "order": 20,
      //   "componentId": "app-component-two",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp4",
      //   "order": 9,
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // },
      // {
      //   "id": "comp5",
      //   "order": 50,
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // }
    ],
    "sidebar-first": [
      // {
      //   "id": "comp6",
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // }
    ],
    "sidebar-second": [
      // {
      //   "id": "comp7",
      //   "componentId": "app-component-three",
      //   "urlPattern": "route3/:id"
      // },
      // {
      //   "id": "comp8",
      //   "order": "top",
      //   "componentId": "app-component-one",
      //   "urlPattern": "route1/:id",
      //   "args": { test: [], testTwo: {}}
      // },
      // {
      //   "id": "comp9",
      //   "componentId": "app-component-three",
      //   "urlPattern": "route1/:id"
      // },
      // {
      //   "id": "comp10",
      //   "componentId": "app-component-two",
      //   "urlPattern": "route1/:id"
      // },
      // {
      //   "id": "comp11",
      //   "order": 9,
      //   "componentId": "app-component-three",
      //   "urlPattern": "route2/:id"
      // }
    ]
  }
}