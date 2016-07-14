assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'
Backbone = require 'backbone'
Vigor = require '../../../dist/vigorjs.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly
ActiveInstanceDefinitionModel = __testOnly.ActiveInstanceDefinitionModel
FilterModel = __testOnly.FilterModel
router = __testOnly.router
MockComponent = require '../MockComponent'

describe 'ActiveInstanceDefinitionModel', ->
  sandbox = undefined
  activeInstanceDefinitionModel = undefined

  beforeEach ->
    activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel()
    sandbox = sinon.sandbox.create()

  afterEach ->
    do sandbox.restore
    do activeInstanceDefinitionModel.dispose
    activeInstanceDefinitionModel = undefined


  describe 'initialize', ->
    it 'should add a listener on "add" with _onAdd as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'add', activeInstanceDefinitionModel._onAdd

    it 'should add a listener on "remove" with _onRemove as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'remove', activeInstanceDefinitionModel._onRemove

    it 'should add a listener on "change:instance" with _onInstanceChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:instance', activeInstanceDefinitionModel._onInstanceChange

    it 'should add a listener on "change:urlParams" with _onUrlParamsChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:urlParams', activeInstanceDefinitionModel._onUrlParamsChange

    it 'should add a listener on "change:order" with _onOrderChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:order', activeInstanceDefinitionModel._onOrderChange

    it 'should add a listener on "change:target" with _onTargetChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:target', activeInstanceDefinitionModel._onTargetChange

    it 'should add a listener on "change:componentClassName" with _onComponentClassNameChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:componentClassName', activeInstanceDefinitionModel._onComponentClassNameChange

    it 'should add a listener on "change:serializedFilter" with _onSerializedFilterChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'listenTo'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith activeInstanceDefinitionModel, 'change:serializedFilter', activeInstanceDefinitionModel._onSerializedFilterChange

    it 'should add call _updateUrlParamsCollection', ->
      updateUrlParamsModelSpy = sandbox.spy activeInstanceDefinitionModel, '_updateUrlParamsCollection'
      do activeInstanceDefinitionModel.initialize
      assert updateUrlParamsModelSpy.called




  describe 'tryToReAddStraysToDom', ->

    beforeEach ->
      $('body').append '<div class="component-area--header"></div>'
      $('body').append '<div class="component-area--footer"></div>'

      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-1"}
        target: $('.component-area--header')
      , silent: true

    afterEach ->
      do $('.component-area--header').remove
      do $('.component-area--footer').remove

    it 'should call _isAttached', ->
      isAttachedSpy = sandbox.spy activeInstanceDefinitionModel, '_isAttached'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert isAttachedSpy.called

    it 'if instance is not attached it should call _addInstanceInOrder', ->
      sandbox.stub activeInstanceDefinitionModel, '_isAttached', -> return false
      addInstanceInOrderSpy = sandbox.spy activeInstanceDefinitionModel, '_addInstanceInOrder'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert addInstanceInOrderSpy.called

    it 'if the instance was added to dom and there is a delegateEvents method
    it should be called', ->
      sandbox.stub activeInstanceDefinitionModel, '_isAttached', -> return false
      sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder', -> return true
      instance = activeInstanceDefinitionModel.get 'instance'
      delegateEventsSpy = sandbox.spy instance, 'delegateEvents'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert delegateEventsSpy.called

    it 'if the instance was not added to the dom it means that there was no
    target for this instance and therefore it should be disposed', ->
      sandbox.stub activeInstanceDefinitionModel, '_isAttached', -> return false
      sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder', -> return false
      disposeInstanceSpy = sandbox.spy activeInstanceDefinitionModel, '_disposeInstance'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert disposeInstanceSpy.called

    it 'after readdig stray it should call _updateTargetPopulatedState', ->
      sandbox.stub activeInstanceDefinitionModel, '_isAttached', -> return false
      sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder', -> return true
      updateTargetPopulatedStateSpy = sandbox.spy activeInstanceDefinitionModel, '_updateTargetPopulatedState'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert updateTargetPopulatedStateSpy.called

    it 'after failing to readdig stray it should call _updateTargetPopulatedState', ->
      sandbox.stub activeInstanceDefinitionModel, '_isAttached', -> return false
      sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder', -> return false
      updateTargetPopulatedStateSpy = sandbox.spy activeInstanceDefinitionModel, '_updateTargetPopulatedState'
      do activeInstanceDefinitionModel.tryToReAddStraysToDom
      assert updateTargetPopulatedStateSpy.called




  describe 'dispose', ->
    it 'should call _disposeInstance', ->
      disposeInstanceSpy = sandbox.spy activeInstanceDefinitionModel, '_disposeInstance'
      do activeInstanceDefinitionModel.dispose
      assert disposeInstanceSpy.called

    it 'should call _updateTargetPopulatedState', ->
      updateTargetPopulatedStateSpy = sandbox.spy activeInstanceDefinitionModel, '_updateTargetPopulatedState'
      do activeInstanceDefinitionModel.dispose
      assert updateTargetPopulatedStateSpy.called

    it 'should call off', ->
      offSpy = sandbox.spy activeInstanceDefinitionModel, 'off'
      do activeInstanceDefinitionModel.dispose
      assert offSpy.called



  describe '_createInstance', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        componentClassName: 'vigor-component'
        instance: undefined
        target: $('.component-area--header')
      , silent: true

    it 'should create a new instance of the stored componentClass', ->
      assert.equal activeInstanceDefinitionModel.get('instance'), undefined
      componentClass = activeInstanceDefinitionModel.get 'componentClass'
      do activeInstanceDefinitionModel._createInstance
      instance = activeInstanceDefinitionModel.get 'instance'
      assert instance instanceof componentClass

    it 'should call _getInstanceArguments and pass those arguments to the instance
    constructor', ->
      instanceArguments =
        foo: 'bar'
      activeInstanceDefinitionModel.set 'instanceArguments', instanceArguments
      componentClass = activeInstanceDefinitionModel.get 'componentClass'
      constructorSpy = sandbox.spy activeInstanceDefinitionModel.attributes, 'componentClass'
      getInstanceArgumentsSpy = sandbox.spy activeInstanceDefinitionModel, '_getInstanceArguments'

      do activeInstanceDefinitionModel._createInstance

      assert constructorSpy.calledWith instanceArguments
      assert getInstanceArgumentsSpy.called


    it 'should store the instance on the activeInstanceDefinitionModel "instance"
    property', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      assert.equal instance, undefined
      setSpy = sandbox.spy activeInstanceDefinitionModel, 'set'

      do activeInstanceDefinitionModel._createInstance
      instance = activeInstanceDefinitionModel.get 'instance'
      assert instance instanceof MockComponent
      assert setSpy.calledWith 'instance', instance

    it 'should call _updateComponentClassNameOnInstance', ->
      updateComponentClassNameOnInstanceSpy = sandbox.spy activeInstanceDefinitionModel, '_updateComponentClassNameOnInstance'
      do activeInstanceDefinitionModel._createInstance
      assert updateComponentClassNameOnInstanceSpy.called



  describe '_renderInstance', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-1"}
        target: $('.component-area--header')
      , silent: true

    it 'should throw a MISSING_RENDER_METHOD error if the instance does not have
    a render method', ->
      activeInstanceDefinitionModel.set 'instance', new Function(), silent: true
      errorFn = -> do activeInstanceDefinitionModel._renderInstance
      assert.throws (-> errorFn()), /The instance for my-active-instance-definition does not have a render method/

    it 'should call preRender if it exists and is a function on the instance', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      preRenderSpy = sandbox.spy instance, 'preRender'
      do activeInstanceDefinitionModel._renderInstance
      assert preRenderSpy.called

    it 'should call render if it exists and is a function on the instance', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      renderSpy = sandbox.spy instance, 'render'
      do activeInstanceDefinitionModel._renderInstance
      assert renderSpy.called

    it 'should call postRender if it exists and is a function on the instance', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      postRenderSpy = sandbox.spy instance, 'postRender'
      do activeInstanceDefinitionModel._renderInstance
      assert postRenderSpy.called




  describe '_addInstanceInOrder', ->
    $componentArea = undefined
    activeInstanceDefinitionsArr = []

    beforeEach ->
      $('body').append '<div class="component-area--header"></div>'
      $componentArea = $ '.component-area--header'

      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')
        order: 1
      , silent: true

      for i in [1 .. 5]
        activeInstanceDefinitionsArr.push new ActiveInstanceDefinitionModel
          id: "instance-definition-#{i}"
          componentClass: MockComponent
          instance: new MockComponent {id: "instance-#{i}"}
          target: $('.component-area--header')
          order: i

    afterEach ->
      do $('.component-area--header').remove
      _.invoke activeInstanceDefinitionsArr, 'dispose'
      activeInstanceDefinitionsArr = []

    it 'should add activeInstanceDefinitions with an order attribute in an ascending order', ->

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 5

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      assert.equal first, 'instance-1'
      assert.equal second, 'instance-2'
      assert.equal third, 'instance-3'
      assert.equal fourth, 'instance-4'
      assert.equal fifth, 'instance-5'

    it 'it should add components in an ascending order even though there are
    already elements without an order attribute in the dom (elements without
    an order attributes should be pushed to the bottom)', ->

      elements = '<div id="dummy1"></div>'
      elements += '<div id="dummy2"></div>'
      elements += '<div id="dummy3"></div>'

      $componentArea.append elements

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 8

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      sixth = $children.eq(5).attr 'id'
      seventh = $children.eq(6).attr 'id'
      eighth = $children.eq(7).attr 'id'

      assert.equal first, 'instance-1'
      assert.equal second, 'instance-2'
      assert.equal third, 'instance-3'
      assert.equal fourth, 'instance-4'
      assert.equal fifth, 'instance-5'

      assert.equal sixth, 'dummy1'
      assert.equal seventh, 'dummy2'
      assert.equal eighth, 'dummy3'

    it 'it should add components in an ascending order even though there are
    already elements with an order attribute in the dom', ->

      elements = '<div id="dummy1" data-order="3"></div>'
      elements += '<div id="dummy2" data-order="4"></div>'
      elements += '<div id="dummy3" data-order="6"></div>'

      $componentArea.append elements

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 8

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      sixth = $children.eq(5).attr 'id'
      seventh = $children.eq(6).attr 'id'
      eighth = $children.eq(7).attr 'id'

      assert.equal first, 'instance-1'
      assert.equal second, 'instance-2'
      assert.equal third, 'dummy1'
      assert.equal fourth, 'instance-3'
      assert.equal fifth, 'dummy2'
      assert.equal sixth, 'instance-4'
      assert.equal seventh, 'instance-5'
      assert.equal eighth, 'dummy3'

    it 'should add components with order set to "top" first - before any
    other elements', ->
      activeInstanceDefinitionsArr[2].set 'order', 'top'

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 5

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      assert.equal first, 'instance-3'
      assert.equal second, 'instance-1'
      assert.equal third, 'instance-2'
      assert.equal fourth, 'instance-4'
      assert.equal fifth, 'instance-5'

    it 'should add components with order set to "bottom" last - after any
    other elements', ->
      activeInstanceDefinitionsArr[2].set 'order', 'bottom'

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 5

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      assert.equal first, 'instance-1'
      assert.equal second, 'instance-2'
      assert.equal third, 'instance-4'
      assert.equal fourth, 'instance-5'
      assert.equal fifth, 'instance-3'

    it 'should add components without any order attribute last', ->

      activeInstanceDefinitionsArr[2].set 'order', undefined

      _.invoke activeInstanceDefinitionsArr, '_addInstanceInOrder'

      $children = $componentArea.children()
      assert.equal $children.length, 5

      first = $children.eq(0).attr 'id'
      second = $children.eq(1).attr 'id'
      third = $children.eq(2).attr 'id'
      fourth = $children.eq(3).attr 'id'
      fifth = $children.eq(4).attr 'id'

      assert.equal first, 'instance-1'
      assert.equal second, 'instance-2'
      assert.equal third, 'instance-4'
      assert.equal fourth, 'instance-5'
      assert.equal fifth, 'instance-3'

    it 'after adding instance $el to the DOM it should verify that its present
    and if the instance has an onAddedToDom method it should be called', ->

      isAttachedSpy = sandbox.spy activeInstanceDefinitionModel, '_isAttached'
      onAddedToDomSpy = sandbox.spy MockComponent.prototype, 'onAddedToDom'

      do activeInstanceDefinitionModel._addInstanceInOrder

      assert isAttachedSpy.called
      assert onAddedToDomSpy.called

    it 'should return true if the instance is attached to the DOM', ->
      isAttached = do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal isAttached, true

    it 'should return false if the instance is not attached to the DOM', ->
      isAttached = do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal isAttached, true
      do $componentArea.remove

      isAttached = do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal isAttached, false



  describe '_disposeInstance', ->
    activeInstanceDefinitionModel = undefined
    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        instance: new MockComponent {id: "instance-0"}
      , silent: true

    afterEach ->
      do activeInstanceDefinitionModel.dispose

    it 'should call dispose on the instance if it exsists', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      disposeSpy = sandbox.spy instance, 'dispose'
      do activeInstanceDefinitionModel._disposeInstance
      assert disposeSpy.called

    it 'should silently set the value of the instance attribute to undefined', ->
      setSpy = sandbox.spy activeInstanceDefinitionModel, 'set'
      do activeInstanceDefinitionModel._disposeInstance
      assert setSpy.calledWith 'instance', undefined, { silent: true }




  describe '_isTargetPopulated', ->
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      $('body').append '<div class="component-area--header" id="test-header"></div>'

      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')
        order: 1
      , silent: true

    afterEach ->
      do $('.component-area--header').remove

    it 'should return true if passed element has children', ->
      $componentArea = $ '#test-header'
      $componentArea.append '<div class="dummy-component"></div>'
      isPopulated = activeInstanceDefinitionModel._isTargetPopulated()
      assert.equal isPopulated, true

    it 'should return false if passed element has no children', ->
      isPopulated = activeInstanceDefinitionModel._isTargetPopulated()
      assert.equal isPopulated, false




  describe '_updateTargetPopulatedState', ->

    beforeEach ->
      $('body').append '<div class="component-area--header" id="test-header"></div>'

      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        targetPrefix: 'component-area'
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')
      , silent: true

    afterEach ->
      do $('.component-area--header').remove

    it 'should add a --has-components variation class to the component area
      ex: component-area--has-components if it holds components', ->

      $target = activeInstanceDefinitionModel.get 'target'
      assert.equal $target.children().length, 0

      do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal $target.children().length, 1

      do activeInstanceDefinitionModel._updateTargetPopulatedState

      assert $target.hasClass('component-area--has-components')


    it 'should remove the --has-components variation class to the component area
    does not hold any components', ->

      $target = activeInstanceDefinitionModel.get 'target'
      assert.equal $target.children().length, 0

      do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal $target.children().length, 1

      do activeInstanceDefinitionModel._disposeInstance

      assert.equal $target.children().length, 0

      do activeInstanceDefinitionModel._updateTargetPopulatedState

      assert.equal $target.hasClass('component-area--has-components'), false




  describe '_isAttached', ->
    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should return false if element is not present in the DOM', ->
      instance =
        $el: $ '<div/>'

      activeInstanceDefinitionModel.set 'instance', instance, silent: true
      isAttached = activeInstanceDefinitionModel._isAttached()
      assert.equal isAttached, false

    it 'should return true if element is present in the DOM', ->
      instance =
        $el: $ '<div/>'

      $('body').append instance.$el

      activeInstanceDefinitionModel.set 'instance', instance, silent: true
      isAttached = activeInstanceDefinitionModel._isAttached()
      assert.equal isAttached, true




  describe '_getInstanceArguments', ->

    beforeEach ->
      sandbox.stub activeInstanceDefinitionModel, '_createInstance'
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        urlParams:
          foo: 'bar'
        instanceArguments:
          baz: 'qux'

    it 'should append urlParams to the returned (padded) instanceArguments', ->
      instanceArguments = activeInstanceDefinitionModel.get 'instanceArguments'
      assert.deepEqual instanceArguments, baz: 'qux'
      assert.equal instanceArguments.urlParams, undefined

      instanceArguments = do activeInstanceDefinitionModel._getInstanceArguments
      assert.equal instanceArguments.urlParams, activeInstanceDefinitionModel.get('urlParams')

    it 'should append urlParamsCollection to the returned (padded) instanceArguments', ->
      instanceArguments = activeInstanceDefinitionModel.get 'instanceArguments'
      assert.deepEqual instanceArguments, baz: 'qux'
      assert.equal instanceArguments.urlParamsCollection, undefined

      instanceArguments = do activeInstanceDefinitionModel._getInstanceArguments
      assert.equal instanceArguments.urlParamsCollection, activeInstanceDefinitionModel.get('urlParamsCollection')




  describe '_getPrecedingElement', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
      , silent: true

      $('body').append '<div id="dummy1" class="dummy-elements" data-order="1"></div>'
      $('body').append '<div id="dummy2" class="dummy-elements" data-order="2"></div>'
      $('body').append '<div id="dummy3" class="some-other-element"></div>'
      $('body').append '<div id="dummy4" class="dummy-elements" data-order="3"></div>'
      $('body').append '<div id="dummy5" class="dummy-elements" data-order="4"></div>'
      $('body').append '<div id="dummy6" class="dummy-elements" data-order="8"></div>'

    afterEach ->
      do $('.dummy-elements').remove
      do $('.some-other-element').remove

    it 'should return the passed in $el if its data-order attribute is less or
    equal to the order that was passed in as a second argument', ->
      $el = $ '#dummy1'
      order = 1

      $result = activeInstanceDefinitionModel._getPrecedingElement $el, order

      assert.equal $el.data('order'), order
      assert.equal $el.get(0), $result.get(0)

    it 'should recursively walk backwards through each sibling element
    until it it finds the first sibling with an order attribute that is equal
    or lower than the passed in order', ->
      $startEl = $ '#dummy5'
      $expectedElement = $ '#dummy1'
      order = 1
      previousElementSpy = sandbox.spy activeInstanceDefinitionModel, '_getPrecedingElement'
      $result = activeInstanceDefinitionModel._getPrecedingElement $startEl, order

      assert.equal previousElementSpy.callCount, 5
      assert.equal $expectedElement.data('order'), order
      assert.equal $expectedElement.get(0), $result.get(0)

    it 'should return undefined if there is no element in the DOM for the passed in $el', ->
      $startEl = $ '#dummy10'
      order = 1
      $result = activeInstanceDefinitionModel._getPrecedingElement $startEl, order

      assert.equal $result, undefined

    it 'should return undefined if no previous element can be found', ->
      $startEl = $ '#dummy1'
      order = 0
      $result = activeInstanceDefinitionModel._getPrecedingElement $startEl, order

      assert.equal $result, undefined


  describe '_updateUrlParamsCollection', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        urlParams: [
          {
            foo: 'bar',
            id: 1
          },
          {
            splat: 'foo/1'
          }
        ]
      , silent: true

    it 'should update the urlParamsCollection with the urlParams', ->
      urlParamsCollection = activeInstanceDefinitionModel.get 'urlParamsCollection'
      setSpy = sandbox.spy urlParamsCollection, 'set'

      do activeInstanceDefinitionModel._updateUrlParamsCollection

      assert setSpy.calledWith activeInstanceDefinitionModel.get('urlParams')


  describe '_updateComponentClassNameOnInstance', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent()
      , silent: true

    it 'should add the componentClassName on the instance.$el', ->
      componentClassName = 'my-component-class-name'
      instance = activeInstanceDefinitionModel.get 'instance'
      assert.equal instance.$el.hasClass(componentClassName), false

      activeInstanceDefinitionModel.set 'componentClassName', componentClassName

      do activeInstanceDefinitionModel._updateComponentClassNameOnInstance

      assert.equal instance.$el.hasClass(componentClassName), true

    it 'should remove the old componentClassName from the instance.$el if
    it is not the same as the new one', ->
      componentClassName = 'my-component-class-name'
      newComponentClassName = 'my-new-component-class-name'
      instance = activeInstanceDefinitionModel.get 'instance'
      assert.equal instance.$el.hasClass(componentClassName), false

      activeInstanceDefinitionModel.set 'componentClassName', componentClassName

      do activeInstanceDefinitionModel._updateComponentClassNameOnInstance

      assert.equal instance.$el.hasClass(componentClassName), true

      activeInstanceDefinitionModel.set 'componentClassName', newComponentClassName

      do activeInstanceDefinitionModel._updateComponentClassNameOnInstance

      assert.equal instance.$el.hasClass(componentClassName), false
      assert.equal instance.$el.hasClass(newComponentClassName), true

  describe '_onComponentClassNameChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _updateComponentClassNameOnInstance', ->
      updateComponentClassNameOnInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_updateComponentClassNameOnInstance'
      do activeInstanceDefinitionModel._onComponentClassNameChange

      assert updateComponentClassNameOnInstanceStub.called



  describe '_onInstanceChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _renderInstance, _addInstanceInOrder and _updateTargetPopulatedState', ->
      renderInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_renderInstance'
      addInstanceInOrderStub = sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder'
      updateTargetPopulatedStateStub = sandbox.stub activeInstanceDefinitionModel, '_updateTargetPopulatedState'

      do activeInstanceDefinitionModel._onInstanceChange

      assert renderInstanceStub.called
      assert addInstanceInOrderStub.called
      assert updateTargetPopulatedStateStub.called



  describe '_onUrlParamsChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _updateUrlParamsCollection', ->
      updateUrlParamsCollectionStub = sandbox.stub activeInstanceDefinitionModel, '_updateUrlParamsCollection'
      do activeInstanceDefinitionModel._onUrlParamsChange
      assert updateUrlParamsCollectionStub.called



  describe '_onOrderChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _addInstanceInOrder', ->
      addInstanceInOrderStub = sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder'
      do activeInstanceDefinitionModel._onOrderChange
      assert addInstanceInOrderStub.called



  describe '_onTargetChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _addInstanceInOrder', ->
      addInstanceInOrderStub = sandbox.stub activeInstanceDefinitionModel, '_addInstanceInOrder'
      do activeInstanceDefinitionModel._onTargetChange
      assert addInstanceInOrderStub.called




  describe '_onSerializedFilterChange', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _disposeInstance and _createInstance if reInstantiate is set to true', ->
      disposeInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_disposeInstance'
      createInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_createInstance'
      activeInstanceDefinitionModel.set 'reInstantiate', true

      do activeInstanceDefinitionModel._onSerializedFilterChange

      assert disposeInstanceStub.called
      assert createInstanceStub.called

    it 'should not call _disposeInstance and _createInstance if reInstantiate is set to false', ->
      disposeInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_disposeInstance'
      createInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_createInstance'
      activeInstanceDefinitionModel.set 'reInstantiate', false

      do activeInstanceDefinitionModel._onSerializedFilterChange

      assert disposeInstanceStub.notCalled
      assert createInstanceStub.notCalled



  describe '_onAdd', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call _createInstance', ->
      createInstanceStub = sandbox.stub activeInstanceDefinitionModel, '_createInstance'
      do activeInstanceDefinitionModel._onAdd
      assert createInstanceStub.called



  describe '_onRemove', ->

    beforeEach ->
      activeInstanceDefinitionModel.set
        id: 'my-active-instance-definition'
        componentClass: MockComponent
      , silent: true

    it 'should call dispose', ->
      disposeStub = sandbox.stub activeInstanceDefinitionModel, 'dispose'
      do activeInstanceDefinitionModel._onRemove
      assert disposeStub.called
