var componentSettings = {
  conditions: {
    withinTimeSpan: function () {
      var today = new Date().getHours(),
          startTime = 0,
          endTime = 24,
          allowed = (today >= startTime && today <= endTime);
      console.log('is within timespan: ', allowed);
      return allowed;
    }
  },

  components: [{
    id: 'order-component',
    src: 'app.components.FilterComponent',
    conditions: ['withinTimeSpan']
  }],

  targets: {
    main: [
      {
        id: 'order-instance-1',
        componentId: 'order-component',
        order: 1,
        args: {
          order: '1',
          background: 'aqua'
        },
        urlPattern: 'global'
      },
      {
        id: 'order-instance-2',
        componentId: 'order-component',
        order: 2,
        args: {
          order: '2',
          background: 'green'
        },
        urlPattern: 'global'
      },
      {
        id: 'order-instance-3',
        componentId: 'order-component',
        order: 3,
        args: {
          order: '3',
          background: 'silver'
        },
        urlPattern: 'global'
      },
      {
        id: 'order-instance-4',
        componentId: 'order-component',
        order: 4,
        args: {
          order: '4',
          background: 'yellow'
        },
        urlPattern: 'global'
      },
      {
        id: 'order-instance-5',
        componentId: 'order-component',
        order: 5,
        args: {
          order: '5',
          background: 'pink'
        },
        urlPattern: 'global'
      }
    ]
  }
}
