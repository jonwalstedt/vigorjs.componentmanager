### <a name="component-definitions"></a> ComponentDefinitions
ComponentDefinitions or componentDefinitionModels are the models that contains the definition of each component created by the componentManager. It stores a reference to the class to create instances from and also the conditions (if any) that should apply to create any instances of that class.

To define your componentDefinitions you add your componentDefinition objects to the components array in the [componentSettings](#settings).

The only required properties for a componentDefinition is **id** and **src**. But a componentDefinition could also contain the default properties **args**, **conditions** and **maxShowCount**. All properties are undefined by default. Se the description for each below:

#### Example of an componentDefinition object.
```javascript
componentDefinition = {
  id: 'my-component',
  src: 'components/my-component',
  args: {
    myArg: 'myArgValue'
  },
  conditions: ['isLoggedIn', 'hasNewMessage'],
  maxShowCount: 3
}
```

#### ComponentDefinition Properties

<table class="docs-table">
  <thead>
    <tr>
      <th class="docs-table__column docs-table__column-1">Property</th>
      <th class="docs-table__column docs-table__column-2">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="docs-table__column docs-table__column-1">
        **id** String (required)
      </td>
      <td class="docs-table__column docs-table__column-2">
        The id property is required. It should be a uniqe identifier for the componentDefinition and it should be a string. InstanceDefinitions will reference this id to know what class to create the instance from.
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **src** String / Function (required)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The src property is also required and can be either a string or a constructor function. If it is a string it should either be a url, a path that can be **required** by a AMD or CommonJS module loader or a namespace path to the class starting from the window object (leaving out the window object it self), ex: src: **'app.components.Chart'**.</p>

        <p>If you are using a AMD ocr CommonJS module loader the string will always be required unless its a url. It will not try to find the class on the window object even if you send in a string like **'app.components.Chart'**.</p>

        <p>If the string is a **url** (ex. **'http://www.google.com'**) the component manager will use the [IframeComponent](#iframe-component) as a class for any instanceDefinition referencing this componentDefinition.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **args** Object
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The args property is an object containing any key value pairs you like. When an instanceDefinition reference this componentDefinition that instanceDefinitions args will extend this args object, it will then be passed as an argument to the created instance.</p>

        <p>This means that all instanceDefinitions referencing a componentDefinition with an args object will get that object passed to its instance upon instantiation.</p>

        <p>Each instanceDefinitions args object may override properties on the componentDefinitions args object.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **conditions** String / Array / Function
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>A condition for a componentDefinition or instanceDefinition should be a function returning true or false. One or multiple conditions can be used to help determine if an instance of the component should be created or not.</p>

        <p>Instead of a function you may also use a string that will be used as a key for a condition registered in the conditions property of the [componentSettings](#settings) object (or conditions added using the addConditions method).</p>

        <p>You can mix both of these methods and pass an array containing functions or strings or both. All conditions will have to return true to have the instance created.</p>

        <p>If the instanceDefinition have conditions of its own both the conditions of the componentDefinition and the instanceDefinition will have to return true for the instance to be created.</p>

        <p>Note that conidtions defined on the componentDefinition will apply to all instances of that component.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **maxShowCount** Number
      </td>
      <td class="docs-table__column docs-table__column-2">
        The property maxShowCount should be a number if defined. If used it will limit the number of times a instance of that component may be created. For an example you could set it to 1 if you want to display a component only one time - even if other filters pass.
      </td>
    </tr>

  </tbody>
</table>


#### Example
Here is an example of an componentDefinition:
```javascript
  {
    id: 'my-chart', //a unique string
    src: 'components/chart', // path to be required
    args: {
      type: 'bar-chart' // arguments to pass to instance
    },
    conditions: ['correct-width', function (..) {}], // conditions for when to allow instance to be created
    maxShowCount: 1 // instances of this component may only be created/shown once
  }
```

and this is how it would look in the settings object:

```javascript
settings = {
  componentSettings: {
    conditions: {
      ...
    },
    components: [
      {
        id: 'my-chart'
        src: 'components/chart'
        args: {
          type: 'bar-chart'
        }
        conditions: ['correct-width', function (..) {}]
        maxShowCount: 1
      }
    ],
    instances: [
      ...
    ]
  }
}
```

#### Custom Properties
In addition to the default properties you can add any properties you like to a componentDefinition. Custom properties can then be used to refine the filter and target specific instanceDefinitions belonging to the componentDefinition that has the custom property. The custom properties would then also have to be used when creating the filter which would be passed to the refresh method. See example below.

```javascript
componentSettings: {
  components: [
    {
      id: 'my-component',
      src: 'components/chart',
      myCustomProperty: 'componentVal'
    }
  ],
  instances: [
    {
      id: 'my-instance',
      componentId: 'my-component',
      targetName: 'body'
    }
  ]
}
```

In the example above the custom property myCustomProperty is set on the componentDefinition with the value 'componentVal'. The filter below  would create a new instance of the component 'my-component' using the information from the instanceDefinition 'my-instance'.

```javascript
componentManager.refresh({
  myCustomProperty: 'componentVal'
});
```

Custom properties on the componentDefinition may be overridden by custom properties on a intanceDefinition that belongs to that componentDefinition.