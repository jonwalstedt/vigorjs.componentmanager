### <a name="setWhitelistedOrigins"></a> setWhitelistedOrigins

The setWhitelistedOrigins method sets the whitelisted origin (or origins) that will be allowed to send messages to instances created by the componentManager. It takes a string (the origin to use) or an array of origins as an argument.

This method will be called internally during initialization to update the whitelistedOrigins from the whitelistedOrigins property in the [settings ojbect](#settings) (if it is set). You usually do not have to call this method after initialization unless you intend to change the whitelisted origins  on the fly.

```javascript
componentManager.setWhitelistedOrigins('http://myorigin.com');
```

or

```javascript
componentManager.setWhitelistedOrigins(['http://myorigin.com', 'http://mysecondorigin.com']);
```

The whitelistedOrigins defaults to 'http://localhost:3000' and it returns the componentManager instance.