### <a name="addConditions"></a> addConditions

The addConditions method takes an object containing the condition methods to run and a silent flag that determines if the change should trigger an event or not (**the silent flag defaults to `false`**). The passed object will be merged with the conditions object registered during initialization.

To run these method you reference their keys in either the componentDefinitions or instanceDefinitions `conditions` property.

Each condition method will receive the active filter and the args object of the componentDefinition or instanceDefinition if it is defined.


Example:
```javascript
var silent = true,
    conditions = {
      isLoggedIn: function (filter, args) {
        return args.user.isLoggedIn();
      },
      hasNewMessage: function (filter, args) {
        return args.user.hasNewMessage();
      }
    }

componentManager.addConditions(conditions, silent);
```

To use the methods reference them in the componentDefinitions or instanceDefinitions like below:
```javascript
  componentSettings: {
    components: [
      {
        id: 'my-component',
        src: 'components/my-component'
      }
    ],

    instances: [
      {
        id: 'instance-1',
        componentId: 'my-component',
        targetName: 'body',
        urlPattern: 'foo/:bar',
        conditions: ['isLoggedIn', 'hasNewMessage'],
        args: {
          user: app.userModel
        }
      }
    ]
  }
```

For more info see [conditions](#conditions) documentation and the [conditions example](/examples/filter-by-conditions).

The addConditions method returns the componentManager instance.