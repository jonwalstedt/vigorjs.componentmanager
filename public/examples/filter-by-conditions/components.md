```javascript
var componentSettings = {
  conditions: {
    withinTimeSpan: function () {
      var today = new Date().getHours(),
          startTime = 0,
          endTime = 24,
          allowed = (today >= startTime && today <= endTime);
      console.log('is within timespan: ', allowed);
      return allowed;
    },
    hasCorrectTitle: function (filter, args) {
      return args.title == 'id: filter-instance-2';
    },
    hasCorrectBackground: function (filter, args) {
      return args.background == '#9F9EE8';
    }
  },

  components: [{
    id: 'filter-condition-component',
    src: 'ExampleComponent', // ExampleComponent.js in the examples directory - exposed on window
    conditions: ['withinTimeSpan']
  }],

  targets: {
    main: [
      {
        id: 'filter-instance-1',
        componentId: 'filter-condition-component',
        args: {
          title: 'id: filter-instance-1',
          background: '#9FEDFF'
        }
      },

      {
        id: 'filter-instance-2',
        componentId: 'filter-condition-component',
        conditions: ['hasCorrectTitle', 'hasCorrectBackground'],
        args: {
          title: 'id: filter-instance-2',
          background: '#9F9EE8'
        }
      }
    ]
  }
}
```
