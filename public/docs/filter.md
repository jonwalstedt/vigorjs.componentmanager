### <a name="filter"></a> Filter object

The componentManager works like a funnel, you start by defining components (componentDefinitions) and then a list of instances (instanceDefinitions) of those components. Each componentDefinition and each instanceDefinition may have different properties (ex. condition methods, filterString, showCount, urlPatterns etc.) that will be used to decide if it makes it through the funnel.

To actually filter on those properties you call the refresh method and pass a filter object (calling the method without the filter object will create all instances at once - assuming that their targets are available).

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
      The url property can be any valid **url fragment** (hash part of the url - whats returned by Backbone.history.fragment). It will be matched against the urlPattern property on any instanceDefinition that has it defined. Ex: the url 'articles/2010/12/1' would match the urlPattern: 'articles/:section(/:subsection)(/:id)'
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **filterString** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **includeIfMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **excludeIfMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **hasToMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
      </td>
    </tr>

    <tr>
      <td class="docs-table__column docs-table__column-1">
        **cantMatch** String / Regexp (optional)
      </td>
      <td class="docs-table__column docs-table__column-2">
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

