### <a name="instance-definitions"></a> instanceDefinitions
InstanceDefinitions or instanceDefinitionModels defines an instance of a componentDefinition. That means that one componentDefinition may have multiple instanceDefinitions. The connection between them is done with an id reference from each instanceDefinition to its componentDefinition's id. So each instanceDefintion have to have the property **componentId** with the id of the componentDefinition (which holds the class to create the instance from).

The only required properties for a instanceDefinition is **id** and **componentId**, but there are many more default properties which can be used to pass arguments, specify instance order and behaviour and of course properties to help out with filtering. See each property and their descriptions below:

#### ComponentDefinition Properties

##### Public properties
These properties are used to decide what component to create the instance from, where to add it and what arguments to pass to it. See the descriptions for details.

<dl class="property-descriptions">
  <dt><strong>id:</strong> String (required)</dt>
  <dd>
    <p>The id property is required. It should be a uniqe identifier for the instanceDefinition and it should be a string.</p>
  </dd>

  <dt><strong>componentId:</strong> String (required)</dt>
  <dd>
    <p>The componentId property is required. It should be the uniqe identifier for the componentDefinition to create instances from and it should be a string.</p>

    <p>This property links one or multiple instanceDefinitions to a componentDefinition.</p>
  </dd>

  <dt><strong>args:</strong> Object</dt>
  <dd>
    <p>The args property is an object containing any key value pairs you like. This args object will be merged to the args object on the componentDefinition (if any) and override any properties that exists in both objects.</p>

    <p>The merged args object will then be passed as an argument to the created instance constructor.</p>
  </dd>

  <dt><strong>order:</strong> Number</dt>
  <dd>
    <p>The order property should be a Number (int) ex: **order: 4**.</p>

    <p>The order property specifies in what order to add instances to the DOM. The order property is also read back from the DOM when adding instances so it will order instances around elements that is not handled by the componentManager as long as they have a data-order="" attribute set on the element.</p>

    <p>If for example you specify the order to 4 on your instance definition and you have a static element already in the DOM with the data attribut data-order="3" your instance will be added after that element.</p>

    See the example: [Reorder components](/examples/reorder-components/) for more information.
  </dd>

  <dt><strong>targetName:</strong> String</dt>
  <dd>
    <p>The targetName property should be a class selector like **'.component-area--sidebar'** and it should have the prefix that you defined in your settings object (default prefix is 'component-area'). If the prefix is not present it will be added for you so if you set the targetName to '.header' it will be changed to be '.component-area--header'. You would of course have to add the class 'component-area--header' to your markup your self.</p>

    <p>The targetName property is not needed if you are using the [alternative sturcture](#alternative-structure) for your componentSettings object since it will be parsed from the object keys..</p>
  </dd>

  <dt><strong>reInstantiate:</strong> Boolean</dt>
  <dd>
    <p>The reInstantiate flag is a boolean wich defaults to **false**. Setting this flag to true will cause the instance to be reInstantiated when matching two differnt filters after eachother.</p>

    <p>If you for an example pass a filter with the url property set to 'foo/1' and your instanceDefinition have the urlPattern 'foo/:id' your component would pass the filter and be instantiated and added to the DOM. If you then do another refresh with the url set to 'foo/2' the default behaviour would be not to reInstantiate the instance since it's already created, rendered and added to the DOM. But with this flag set to true it will force the instance to be recreated and readded whenever the filter change (and it passes the filter).</p>

    <p>To see this in action see the [Filter by url](/examples/filter-by-url/#passing-arguments/news/political) example.</p>
  </dd>
</dl>

##### Filter related properties on the instanceDefinition
These properties are used to decide if the instance passes the filter or not

<dl class="property-descriptions">
  <dt><strong>filterString:</strong> String</dt>
  <dd>
    <p>The filterString property is a string that you can match against the regexp you define in your filter object (includeIfStringMatches, excludeIfStringMatches, hasToMatchString, cantMatchString)</p>
  </dd>

  <dt><strong>includeIfFilterStringMatches:</strong> String / Regexp</dt>
  <dd>
    <p></p>
  </dd>

  <dt><strong>excludeIfFilterStringMatches:</strong> String / Regexp</dt>
  <dd>
    <p></p>
  </dd>

  <dt><strong>conditions:</strong> Array / Function / String</dt>
  <dd>
    <p></p>
  </dd>

  <dt><strong>maxShowCount:</strong> Number</dt>
  <dd>
    <p></p>
  </dd>

  <dt><strong>urlPattern:</strong> String / Array</dt>
  <dd>
    <p></p>
  </dd>
</dl>

