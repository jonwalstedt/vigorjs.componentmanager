## Ordering and reordering components

By setting the order property when defining instances the componentManager will add each instance in order. The order property (like any other property) can be changed on the fly.

Ordering is handled by looking at the data-attribute data-order, which means that components will order them selfs alongside elements thats not handled by the componentManager as long as they have an data-order set.

Changing the order on the fly only changes the property on the targeted instance (not all instances), thats why it takes to clicks to see any change on the 'Increment instance 1s ordernr' button the first time (it will then go from one to two - and since there already is an instance with order 2 it wont move)

### Example Instance definition

    {
      "id": "order-instance-1",
      "componentId": "order-component",
      "order": 1,
      "args": {
        "background": "aqua"
      }
    }
