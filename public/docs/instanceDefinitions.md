### <a name="instance-definitions"></a> instanceDefinitions
InstanceDefinitions or instanceDefinitionModels defines an instance of a componentDefinition. That means that one componentDefinition may have multiple instanceDefinitions. The connection between them is done with an id reference from each instanceDefinition to its componentDefinition's id. So each instanceDefintion have to have the property **componentId** with the id of the componentDefinition (which holds the class to create the instance from).

The only required properties for a instanceDefinition is **id** and **componentId**, but there are many more default properties which can be used to pass arguments, specify instance order and behaviour and of course properties to help out with filtering. See each property and their descriptions below:

#### InstanceDefinition Properties

##### Public properties
These properties are used to decide what component to create the instance from, where to add it and what arguments to pass to it. See the descriptions for details.

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
        The id property is required. It should be a uniqe identifier for the instanceDefinition and it should be a string.
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **componentId** String (required)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The componentId property is required. It should be the uniqe identifier for the componentDefinition to create instances from and it should be a string.</p>

        <p>This property links one or multiple instanceDefinitions to a componentDefinition.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **args** Object
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The args property is an object containing any key value pairs you like. This args object will be merged to the args object on the componentDefinition (if any) and override any properties that exists in both objects.</p>

        <p>The merged args object will then be passed as an argument to the created instance constructor.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **order** Number
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The order property should be a Number (int) ex: **order: 4**.</p>

        <p>The order property specifies in what order to add instances to the DOM. The order property is also read back from the DOM when adding instances so it will order instances around elements that is not handled by the componentManager as long as they have a data-order="" attribute set on the element.</p>

        <p>If for example you specify the order to 4 on your instance definition and you have a static element already in the DOM with the data attribut data-order="3" your instance will be added after that element.</p>

        <p>See the example: [Reorder components](/examples/reorder-components/) for more information.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **targetName** String / jQuery object
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>If the targetName is a string is a string it should be a class selector like **'.component-area--sidebar'** and it should have the prefix that you defined in your settings object (default prefix is 'component-area'). If the prefix is not present it will be added for you so if you set the targetName to '.header' it will be changed to be '.component-area--header'. You would of course have to add the class 'component-area--header' to your markup your self.</p>

        <p>The targetName property could also be a jquey object like $('.my-element')</p>

        <p>The targetName property is not needed if you are using the [alternative sturcture](#alternative-structure) for your componentSettings object since it will be parsed from the object keys..</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **reInstantiate** Boolean
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The reInstantiate flag is a boolean wich defaults to **false**. Setting this flag to true will cause the instance to be reInstantiated when matching two differnt filters after eachother.</p>

        <p>If you for an example pass a filter with the url property set to 'foo/1' and your instanceDefinition have the urlPattern 'foo/:id' your component would pass the filter and be instantiated and added to the DOM. If you then do another refresh with the url set to 'foo/2' the default behaviour would be not to reInstantiate the instance since it's already created, rendered and added to the DOM. But with this flag set to true it will force the instance to be recreated and readded whenever the filter change (and it passes the filter).</p>

        <p>To see this in action see the [Filter by url](/examples/filter-by-url/#passing-arguments/news/political) example.</p>
      </td>
    </tr>
  </tbody>
</table>

##### Filter related properties on the instanceDefinition
These properties are used to decide if the instance passes the filter or not.

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
        **filterString** String
      </td>
      <td class="docs-table__column docs-table__column-2">
        The filterString property is a string that you can match against the regexp you define in your filter object (by adding your regexp to one of these filter properties: includeIfMatch, excludeIfMatch, hasToMatch, cantMatch).
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **includeIfFilterStringMatches** String / Regexp
      </td>
      <td class="docs-table__column docs-table__column-2">
        The includeIfFilterStringMatches property is a string or a regexp that will be matched against the filterString defined on the filter object. If the regexp matches the filterString the instance will be created. If includeIfFilterStringMatches is defined and does not match the filterString the instanceDefinition will not pass the filter.
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **excludeIfFilterStringMatches** String / Regexp
      </td>
      <td class="docs-table__column docs-table__column-2">
        The excludeIfFilterStringMatches property is a string or a regexp that will be matched against the filterString defined on the filter object. If the regexp matches filterString in the filter object the instance will be excluded.
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **conditions** Array / Function / String
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>A condition for a componentDefinition or instanceDefinition should be a function returning true or false. One or multiple conditions can be used to help determine if an instance of the component should be created or not.</p>

        <p>Instead of a function you may also use a string that will be used as a key for a condition registered in the conditions property of the [componentSettings](#settings) object (or conditions added using the addConditions method).</p>

        <p>You can mix both of these methods and pass an array containing functions or strings or both. All conditions will have to return true to have the instance created.</p>

        <p>If the componentDefinition that the instanceDefinition references have conditions of its own both the conditions of the instanceDefinition and the componentDefinition will have to return true for the instance to be created.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **excludeIfFilterStringMatches** String / Regexp
      </td>
      <td class="docs-table__column docs-table__column-2">
        The excludeIfFilterStringMatches property is a string or a regexp that will be matched against the filterString defined on the filter object. If the regexp matches filterString in the filter object the instance will be excluded.
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **maxShowCount** Number
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The property maxShowCount should be a number if defined. The instanceDefinitions maxShowCount overrides the componentDefinitions maxShowCount property.</p>

        <p>If used it will limit the number of times a instance of that component may be created. For an example you could set it to 1 if you want to display a component only one time - even if other filters pass.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **urlPattern** String / Array
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The urlPattern property should be a string in the form of a Backbone url pattern / route or an array containing multiple url patterns.</p>

        <p>This pattern will be used when filtering with the url property on the filter object that is passed to the refresh method. If your instanceDefinitions urlPattern matches the url (and all other filters pass) your instance will be created.</p>

        <p>By passing multiple urlPatterns you can have the same instance active across multpile urls without reinstantiation. For an example: if you set the urlPattern to ['home', 'products/:id'] your instance would be created once when matching 'home' and then still keep the same instance active when navigating to any page that matches the 'products/:id' pattern (products/1, products/2 etc.)</p>

        <p>You can also set the urlPattern to **'global'** to have it match any url. This is useful if you want an instance of your component to always stay on page, like a header or a main menu.</p>

        <p>See the [Filter by url](/examples/filter-by-url) example.</p>
      </td>
    </tr>
  </tbody>
</table>

#### Custom Properties
In adition to the default values you can add any properties you like to a instanceDefinition. These properties will then be used to filter out the instanceDefinitions. The custom properties would then also have to be used when creating the filter which would be passed to the refresh method. See example below.

Custom properties on a instanceDefinition overrides custom properties on it's componentDefinition.

See the section 'Custom properties' on [componentDefinitions](#component-definitions) for mor information and examples.