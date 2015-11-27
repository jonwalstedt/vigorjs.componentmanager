### <a name="filter"></a> Filter object

The componentManager works like a funnel, you start by defining components (componentDefinitions) and then a list of instances (instanceDefinitions) of those components. Each componentDefinition and each instanceDefinition may have different properties (ex. condition methods, filterString, showCount, urlPatterns etc.) that will be used to decide if it makes it through the funnel.

The filter object can contain the following properties:

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
        **url** String (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The url property can be any valid **url fragment** (hash part of the url - whats returned by Backbone.history.fragment). It will be matched against the urlPattern property on any instanceDefinition that has it defined. Ex: the url 'articles/2010/12/1' would match the urlPattern: 'articles/:section(/:subsection)(/:id)'.</p>

        <p>See the [Filter by url](/examples/filter-by-url) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **filterString** String (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The filterString can be any string and it is intended to be used together with the instanceDefinition properties includeIfFilterStringMatches (string / regexp) and excludeIfFilterStringMatches (string / regexp).</p>

        <p>By passing a filterString together with your filter each instanceDefinition that has includeIfFilterStringMatches will check if that string or regular expression matches the filterString in the filter. If it matches the instance will be created (assuming all other filters passes), if it does not match it will not be created.</p>

        <p>The excludeIfFilterStringMatches works the opposite way, if it the string or regular expression matches the filterString in the filter the instance will be excluded - even if other filters passes.</p>

        <p>See the [Filter by string](/examples/filter-by-string) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **includeIfMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The includeIfMatch property of the filter should be a string or a regular expression and it is intended to use on filterStrings defined on instanceDefinitions (note that this is not the same filterString as the one described above).</p>

        <p>If a instanceDefiniton has a filterString and that string matches the string or regexp defined in the includeIfMatch property of the filter a instance will be created and added to the DOM.</p>

        <p>This filter property also allows the filterString on instanceDefinitions to be undefined. If they are undefined they will still pass this filter.</p>

        <p>See the [Filter by string](/examples/filter-by-string) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **excludeIfMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
        <p>The excludeIfMatch property of the filter should be a string or a regular expression and it is intended to use on filterStrings defined on instanceDefinitions.</p>

        <p>If a instanceDefiniton has a filterString and that string matches the string or regexp defined in the excludeIfMatch property of the filter a instance will be excluded and will not be added to the DOM.</p>

        <p>This filter property also allows the filterString on instanceDefinitions to be undefined. If they are undefined they will still pass this filter.</p>

        <p>This is intended to use in combination with other filters, ex: if a instanceDefinition has a urlPattern that passes but a filterString that says that it is in a specific language (filterString: 'lang=en_GB') and you want to exclude that instance because the user is using another language. That could then be achieved by setting excludeIfMatch to 'lang=en_GB'.</p>

        <p>See the [Filter by string](/examples/filter-by-string) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **hasToMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">

        <p>This filter property does not allow the filterString on instanceDefinitions to be undefined. If they are undefined they will fail this filter.</p>

        <p>See the [Filter by string](/examples/filter-by-string) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **cantMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">

        <p>This filter property does not allow the filterString on instanceDefinitions to be undefined. If they are undefined they will fail this filter.</p>

        <p>See the [Filter by string](/examples/filter-by-string) examples.</p>
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **options** Object (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>
  </tbody>
</table>

To actually filter on those properties you call the refresh method and pass a filter object. Calling the method without the filter object will create all instances at once - assuming that their targets are available.

The filtering process is inclusive, it always tries to include instanceDefinitions unless some filter fail. That means that if a instanceDefinition does not have the necessary property to match a certain filter it will, by default, still pass the filter (ex if you filter using the url property and a instanceDefinition does not have a urlPattern the url filter would be ignored and the instance would be created).

Note that all properties in the filter are optional and combinable in any way.

Take a look at the different examples below:

In the example below the the instance would be created since the instanceDefinitions urlPattern does match the url.
```javascript
var componentSettings, filter;

componentSettings = {
  components: [
    {
      id: 'hello-world-component',
      src: 'components/hello-world'
    }
  ],
  instances: [
    {
      id: 'hello-world-instance',
      componentId: 'hello-world-component',
      targetName: 'body',
      urlPattern: 'foo/:id'
    }
  ]
}

filter = {
  url: 'foo/1'
};

componentManager.initialize(componentSettings);
componentManager.refresh(filter);
```

In the example below the the instance would not be created since the instanceDefinitions urlPattern does not match the url.
```javascript
var componentSettings, filter;

componentSettings = {
  components: [
    {
      id: 'hello-world-component',
      src: 'components/hello-world'
    }
  ],
  instances: [
    {
      id: 'hello-world-instance',
      componentId: 'hello-world-component',
      targetName: 'body',
      urlPattern: 'foo/:id'
    }
  ]
}

filter = {
  url: 'bar/1'
};

componentManager.initialize(componentSettings);
componentManager.refresh(filter);
```

In the example below the the instance would still be created since the instanceDefinitions does not have a urlPattern defined and the only filter property defined is the url.
```javascript
var componentSettings, filter;

componentSettings = {
  components: [
    {
      id: 'hello-world-component',
      src: 'components/hello-world'
    }
  ],
  instances: [
    {
      id: 'hello-world-instance',
      componentId: 'hello-world-component',
      targetName: 'body'
    }
  ]
}

filter = {
  url: 'foo/1'
};

componentManager.initialize(componentSettings);
componentManager.refresh(filter);
```

#### Custom properties
TODO: fixme
