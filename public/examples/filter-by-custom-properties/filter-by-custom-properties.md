## Filter By Custom Properties

You can also filter on any custom properties you like by adding properties to your componentDefinitions or instanceDefinitions and then add the desired properties to your filter.

Any properties thats not a part of the default properties on the componentDefinition and instanceDefinition models will be used when filtering on custom properties. The same applies to the filter, so if you add any properties on the filter that is not a part of the default ones the componentManager will go through and merge the custom properties from each instanceDefinition with its referenced componentDefinition and then try to match those properties with whats been provieded in the filter.

That means that you can apply a custom property ex: type: 'my-custom-component' to your componentDefinition and then if needed you can override that type on one of the instanceDefinitions that is referencing that componentDefinition.

Try it out below:

