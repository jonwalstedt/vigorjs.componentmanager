### <a name="getActiveFilter"></a> getActiveFilter

Returns the currently applied filter of the componentManager. The filter is updated by running the [refresh](#refresh) method with [filter object](#filter).

```javascript
var currentlyAppliedFilter,
filter = {
  url: my/current/route,
  includeIfMatch: 'lang=en_GB'
}

componentManager.refresh(filter);

currentlyAppliedFilter = componentManager.getFilter();

// The currentlyAppliedFilter is the same as the filter.
```
