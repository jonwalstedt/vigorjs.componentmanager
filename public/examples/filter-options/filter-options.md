## Filter options

When filtering components in the componentManager you can set different options depending on the desired result.

The available options (and their default values) are:

    options: {
      add: true,
      remove: true,
      merge: true,
      invert: false,
      forceFilterStringMatching: false
    }

Add and remove are just what you would expect, if you set add to false and filter it will not add the matching components, but if remove is set to true it will remove any components that does not match the filter.

The same thing applies to the remove property. If you filter components and set remove to false it will not remove the previous set of components but it will still add your new set of components (if add is set to true). The old components will stay active until you do another refresh with the remove option set to true.

This sort of behaviour could be useful when doing transitions. If you for an example are animating in new components and don't want to remove the old ones until the animation is complete you pass your filter with the remove option set to false. When the animation is done you do another refresh with the same filter but with the remove option set to true. This will remove the old components since they no longer matches the filter and it will not affect the active (new) components since they are already active - they will not be reinstantiated just because you do another refresh with the same filter. In the [Example App](/examples/example-app/) you can see this in action.

Merge will update existing active instanceDefinitions if set to true, if set to false any active componentDefinitions that might have changed since the last refresh will be ignored.

Invert will invert the filter and return all components that doesn't match the filter.

ForceFilterStringMatching is used in combination with the filters includeIfMatch, excludeIfMatch, hasToMatch or cantMatchtring to allow or disallow components that does not have a filterString set (enabled it will make instanceDefinitions active only when the filter is doing string matching - even if other filters matches). See the [Filter by string](/examples/filter-by-string) example.

Play around with the example below to get a better understanding of the different options.