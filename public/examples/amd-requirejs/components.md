```javascript
define (function (require) {

  var componentSettings = {
    components: [{
      id: 'menu-component',
      src: 'components/menu',
    }],
    targets: {
      main: [
        {
          id: 'menu-instance',
          componentId: 'menu-component',
          urlPattern: 'add-components'
        }
      ]
    }
  }
  return componentSettings;
});

```
