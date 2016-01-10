### <a name="components"></a> Components

The componentManager main purpose is to create and dispose instances of components. In this case a component is typically a View of some sort, either a Backbone.View or a view or class that exposes the interface of a larger component (see the [example app](/examples/example-app) for examples of more complex components).

There are some required properties and methods that needs to be exposed and some optional methods that will be called by the componentManager if they exists, see below.

<div class="docs-table-wrapper">
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
          `$el` jQuery object (required)
        </td>
        <td class="docs-table__column docs-table__column-2">
          A jQuery object containing a reference to the main DOM element of the component.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `render` method (required)
        </td>
        <td class="docs-table__column docs-table__column-2">
          Typically the render method should update the this.$el element with the rendered state of the component
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `dispose` method (required)
        </td>
        <td class="docs-table__column docs-table__column-2">
          The dispose method should clean up and remove the component. Typically it would remove all event listeners, variables and elements used within the component.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `preRender` method (optional)
        </td>
        <td class="docs-table__column docs-table__column-2">
          This method will be called before render if it is defined.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `postRender` method (optional)
        </td>
        <td class="docs-table__column docs-table__column-2">
          This method will be called after render if it is defined.
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `delegateEvents`  method (optional)
        </td>
        <td class="docs-table__column docs-table__column-2">
          <p>Components might get reparented if you remove parent DOM elements without disposing the instance and add a new DOM element with the same class and call refresh on the componentManager.</p>

          <p> In that case the existing instance would be added to the new DOM element and if the instance have a delegateEvents method it would be called to readd event listeners that was tied to the previous element.</p>

          <p>This scenario could in most cases be avoided by not removing componentAreas without first removing the active instances in the componentManager by calling refresh with the new filter.</p>

          <p>See delegateEvents on [Backbone.Views](http://backbonejs.org/#View-delegateEvents).</p>
        </td>
      </tr>

      <tr>
        <td class="docs-table__column docs-table__column-1">
          `receiveMessage` method (optional)
        </td>
        <td class="docs-table__column docs-table__column-2">
          This method will be called if you use the `postMessageToInstance` method on the componentManager. It will receive a message (can be anything) as argument.
        </td>
      </tr>
    </tbody>
  </table>
</div>

A minimal component could be this:

```javascript
var FilterComponent = Backbone.View.extend({
  render: function () {
    this.$el.html('hello world');
  },

  dispose: function () {
    this.remove();
  }
});
```

Or this:
```javascript
var ExampleComponent = function () {
  this.$el = $('<div class="my-component"/>');
};

ExampleComponent.prototype.render = function () {
  this.$el.html('hello world');
};

ExampleComponent.prototype.dispose = function () {
  this.$el.remove();
  this.$el = undefined;
};
```

Or this:
```javascript
var ExampleComponent = Backbone.View.extend({
  template: _.template("<button class='hello-btn'>hello: <%= name %></button>");
  events: {
    "click .hello-btn": '_onHelloBtnClick'
  },

  initialize: function () {
    this.listenTo(this.model, 'change', _.bind(this.render, this));
  },

  preRender: function () {
    this.$el.addClass('transition');
  },

  render: function () {
    this.$el.html(this.template(this.model.toJSON()));
  },

  postRender: function () {
    this.$el.removeClass('transition');
  },

  dispose: function () {
    this.remove();
  },

  _onHelloBtnClick: function () {
    alert('hello');
  }
});
```

Or anything you like as long as it exposes the required properties and methods above.

It's recommend that you group all files that belong to a component under the same folder, ex like this:

```
components
│
│─── bar-chart
│    │   BarChartView.js
│    │   BarChartModel.js
│    │   main.js
│    │
│    ├─── css
│    │   │   main.scss
│    │   │   ...
│    │
│    └─── templates
│        bar-chart-template.html
│        │   ...
│
│
│─── calendar
│    │   CalendarView.js
│    │   CalendarModel.js
│    │   main.js
│    │
│    ├─── css
│    │   │   main.scss
│    │   │   ...
│    │
│    └─── templates
│        calendar-template.html
│        │   ...
```