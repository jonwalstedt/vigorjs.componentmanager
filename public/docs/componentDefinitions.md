### <a name="component-definitions"></a> componentDefinitions
ComponentDefinitions or componentDefinitionModels are the models that contains the definition of each component created by the componentManager. It stores a reference to the class to create the instance from and and also the conditions (if any) that should apply to create any instances of that class.

To define your componentDefinitions you add an array of componentDefinitions to the <a href="#settings">componentSettings object</a> passed to the componentManager during initialization.

The only required properties for a componentDefinition is **id** and **src**. But a componentDefinition could also contain the properties **args**, **conditions** and **maxShowCount**. All properties are undefined by default. Se the description for each below:

#### ComponentDefinition Properties
<dl class="property-descriptions">
  <dt><strong>id:</strong> String (required)</dt>
  <dd>
    <p>The id property is required. It should be a uniqe identifier for the componentDefinition and it should be a string. InstanceDefinitions will reference this id to know what class to create the instance from.</p>
  </dd>

  <dt><strong>src:</strong> String / Function (required)</dt>
  <dd>
    <p>The src property is also required and can be either a string or a constructor function. If it is a string it should either be a url or a namespace path to the class starting from the window object (leaving out the window object it self), ex: src: **'app.components.Chart'**.</p>

    <p>If the string is a **url** (ex. **'http://www.google.com'**) the component manager will use the [IframeComponent](#iframe-component) as a class for any instanceDefinition referencing this componentDefinition.</p>
  </dd>

  <dt><strong>args:</strong> Object</dt>
  <dd>
    <p>The args property is an object containing any key value pairs you like. When an instanceDefinition reference this componentDefinition that instanceDefinitions args will extend this args object, it will then be passed as an argument to the created instance.</p>

    <p>This means that all instanceDefinitions referencing a componentDefinition with an args object will get that object passed to its instance upon instantiation.</p>

    <p>Each instanceDefinitions args object may override properties on the componentDefinitions args object.</p>
  </dd>

  <dt><strong>conditions:</strong> String / Array / Function</dt>
  <dd>
    <p>A condition for a componentDefinition or instanceDefinition should be a function returning true or false. One or multiple conditions can be used to help determine if an instance of the component should be created or not.</p>

    <p>Instead of a function you may also use a string that will be used as a key for a condition registered in the conditions property of the [componentSettings](#settings) object (or conditions added using the addConditions method).</p>

    <p>You can mix both of these methods and pass an array containing functions or strings or both. All conditions will have to return true to have the instance created.</p>

    <p>If the instanceDefinition have conditions of its own both the conditions of the componentDefinition and the instanceDefinition will have to return true for the instance to be created.</p>

    <p>Note that conidtions defined on the componentDefinition will apply to all instances of that component.</p>
  </dd>

  <dt><strong>maxShowCount:</strong> Number</dt>
  <dd>
    <p>The property maxShowCount should be a number if defined. If used it will limit the number of times a instance of that component may be created. For an example you could set it to 1 if you want to display a component only one time - even if other filters pass.</p>
  </dd>
</dl>

#### Example
```javascript
  {
    id: 'my-component'
    src: 'app.components.MyComponent'
    args: {}
    conditions: ['correct-width', function (..) {}]
    maxShowCount: 2
  }
```

```javascript

settings = {
  componentSettings: {
    conditions: {},
    components: [],
    instances: []
  }
}
```
