## Filter components by conditions
Condition methods can be defined on the conditions object in componentSetting (global conditions) or directly in the conditions property on the instanceDefinition or on the componentDefinition. If you want to reuse a condition method between different components you should assign the method to a key in the conditions object when passing componentSettings, those methods will then be global - accessible for all components simply by using the key from that object in the conditionDefinitions or instanceDefinitions conditions property (see the withinTimeSpan example below).

One or multiple conditions can be set on both a component level and an instance level. If applied on a component level all insances of that component will be affected. If applied on an instance level only that instance will be affected.

In this example we add differnt conditions and update components and instances to only be allowed if the conditions are met.

### Example condition: "withinTimeSpan"
This condition is defined in the components.js file and passed along with the componentSettings object to the initialize method. componentDefinitions and instanceDefinitions then reference this condition by using its key as value for their conditions property. In this case it will allways return true unless you play around with the start and end time.

```javascript
{
  withinTimeSpan: function () {
    var today = new Date().getHours(),
        startTime = 0,
        endTime = 24,
        allowed = (today >= startTime && today <= endTime);
    console.log('is within timespan: ', allowed);
    return allowed;
  }
}
```

### Example condition: "correctWidth"
Components using this condition will only be allowed if the browser width is more than 600px.

```javascript
{
  "correct-width": function () {
    return window.outerWidth > 600;
  }
}
```

Click the "Register condition" to make the condition available for the components, then click either "Add condition to component "filter-instance" or "Add condition to instance "filter-instance-2" depending on if you want the condition to be applied on a component level or instance level.

