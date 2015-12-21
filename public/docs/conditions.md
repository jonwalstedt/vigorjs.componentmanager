### <a name="conditions"></a> Conditions

Conditions are methods that you either set on a [componentDefinition](#component-definitions), an [instanceDefinition](#instance-definitions) or in the conditions object within the componentSettings object (see [settings](#settings)). These methods should return **true** or **false** and.

Condition methods will be passed the active filter and the args object on the instanceDefinition or on the componentDefinition depending on where the condition method is used.

If a condition is set on the componentDefinition and it returns false no instances of that componentDefinition will be created. If it instead is set on an instanceDefinition and it returns false only that instanceDefinition will not be created.

The conditions object in the componentSettings is to be used when you want to reuse the same method as a condition for multiple componentDefinitions or instanceDefinitions. You then add your condition methods to that object and reference it by its key when defining your componentDefinitions or instanceDefinitions.

See example below:

```javascript
settings = {
  componentSettings: {
    conditions: {
      isLoggedIn: function (filter, args) {
        return args.user.isLoggedIn();
      },
      hasNewMessage: function (filter, args) {
        return args.user.hasNewMessage();
      }
    },
    components: [
      {
        id: 'user-profile-component',
        src: 'components/user-profile'
        conditions: 'isLoggedIn',
        args: {
          user: app.userModel;
        }
      },
      {
        id: 'message-alert-component',
        src: 'components/message-alert',
        conditions: ['isLoggedIn', 'hasNewMessage'],
        args: {
          user: app.userModel;
        }
      }
    ],
    instances: [
      {
        id: 'user-profile-instance',
        componentId: 'user-profile-component',
        targetName: 'body',
        urlPattern: 'global'
      },
      {
        id: 'message-alert-instance',
        componentId: 'message-alert-component',
        targetName: 'main',
        urlPattern: 'global'
      }
    ]
  }
}
```

In this example there are two methods defined in the conditions object: isLoggedIn and hasNewMessage. Both componentDefinition uses the 'isLoggedIn' condition which means that all instances of those two components will check to see if the user is logged in before being instantiated, if not they will not be created.

The in addition to the 'isLoggedIn' condition the 'message-alert-component' uses the 'hasNewMessage' condition and will therefore only be created if the user hasNewMessage method returns true.

Both instanceDefinitions ('user-profile-instance' and 'message-alert-instance') could in turn have more conditions in their conditions property. The value of this property could be a string (the key of a method registered in the conditions object), or a function or an array with both strings and functions.

See the [componentDefinition](#component-definitions) and the [instanceDefinition](#instance-definitions) specifications. For more examples see the [conditions example](/examples/filter-by-conditions).
