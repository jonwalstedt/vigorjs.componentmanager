assert = require 'assert'
sinon = require 'sinon'
$ = require 'jquery'
Backbone = require 'backbone'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly
ActiveInstanceDefinitionModel = __testOnly.ActiveInstanceDefinitionModel
FilterModel = __testOnly.FilterModel
router = __testOnly.router
MockComponent = require '../MockComponent'

describe 'ActiveInstanceDefinitionModel', ->
  sandbox = undefined

  beforeEach ->
    sandbox = sinon.sandbox.create()

  afterEach ->
    do sandbox.restore

  describe 'initialize', ->
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel()

    afterEach ->
      do activeInstanceDefinitionModel.dispose

    it 'should add a listener on "add" with _onAdd as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'add', activeInstanceDefinitionModel._onAdd

    it 'should add a listener on "remove" with _onRemove as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'remove', activeInstanceDefinitionModel._onRemove

    it 'should add a listener on "change:instance" with _onInstanceChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'change:instance', activeInstanceDefinitionModel._onInstanceChange

    it 'should add a listener on "change:urlParams" with _onUrlParamsChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'change:urlParams', activeInstanceDefinitionModel._onUrlParamsChange

    it 'should add a listener on "change:order" with _onOrderChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'change:order', activeInstanceDefinitionModel._onOrderChange

    it 'should add a listener on "change:target" with _onTargetChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'change:target', activeInstanceDefinitionModel._onTargetChange

    it 'should add a listener on "change:serializedFilter" with _onSerializedFilterChange as callback', ->
      onSpy = sandbox.spy activeInstanceDefinitionModel, 'on'
      do activeInstanceDefinitionModel.initialize
      assert onSpy.calledWith 'change:serializedFilter', activeInstanceDefinitionModel._onSerializedFilterChange

    it 'should add call _updateUrlParamsModel', ->
      updateUrlParamsModelSpy = sandbox.spy activeInstanceDefinitionModel, '_updateUrlParamsModel'
      do activeInstanceDefinitionModel.initialize
      assert updateUrlParamsModelSpy.called

  describe 'tryToReAddStraysToDom', ->
    activeInstanceDefinitionModel = undefined
    beforeEach ->
      $('body').append '<div class="component-area--header"></div>'
      $('body').append '<div class="component-area--footer"></div>'

      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-1"}
        target: $('.component-area--header')

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
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel()

    afterEach ->
      do activeInstanceDefinitionModel.dispose

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

    it 'should call clear', ->
      clearSpy = sandbox.spy activeInstanceDefinitionModel, 'clear'
      do activeInstanceDefinitionModel.dispose
      assert clearSpy.called

  describe '_createInstance', ->
    activeInstanceDefinitionModel = undefined
    beforeEach ->
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        componentClassName: 'vigor-component'
        instance: undefined
        target: $('.component-area--header')

    afterEach ->
      do activeInstanceDefinitionModel.dispose

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

    it 'should add the componentClassName as a class on the instance.$el DOM element', ->
      componentClass = activeInstanceDefinitionModel.get 'componentClass'
      tempInstance = new componentClass()
      assert.equal tempInstance.$el.hasClass('.vigor-component'), false

      do activeInstanceDefinitionModel._createInstance
      instance = activeInstanceDefinitionModel.get 'instance'
      assert instance.$el.hasClass('vigor-component')

    it 'should store the instance on the activeInstanceDefinitionModel "instance"
    property', ->
      instance = activeInstanceDefinitionModel.get 'instance'
      assert.equal instance, undefined
      setSpy = sandbox.spy activeInstanceDefinitionModel, 'set'

      do activeInstanceDefinitionModel._createInstance
      instance = activeInstanceDefinitionModel.get 'instance'
      assert instance instanceof MockComponent
      assert setSpy.calledWith 'instance', instance

  describe '_renderInstance', ->
    activeInstanceDefinitionModel = undefined
    beforeEach ->
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-1"}
        target: $('.component-area--header')

    afterEach ->
      do activeInstanceDefinitionModel.dispose

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
    activeInstanceDefinitionModel = undefined
    activeInstanceDefinitionsArr = []
    beforeEach ->
      $('body').append '<div class="component-area--header"></div>'
      $componentArea = $ '.component-area--header'

      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')
        order: 1

      for i in [1 .. 5]
        activeInstanceDefinitionsArr.push new ActiveInstanceDefinitionModel
          id: "instance-definition-#{i}"
          componentClass: MockComponent
          instance: new MockComponent {id: "instance-#{i}"}
          target: $('.component-area--header')
          order: i

    afterEach ->
      do $('.component-area--header').remove
      do activeInstanceDefinitionModel.dispose
      activeInstanceDefinitionModel = undefined
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
      assert.equal third, 'instance-3'
      assert.equal fourth, 'dummy1'
      assert.equal fifth, 'instance-4'
      assert.equal sixth, 'dummy2'
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
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        instance: new MockComponent {id: "instance-0"}

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
      assert setSpy.calledWith { 'instance': undefined }, { silent: true }

  describe '_isTargetPopulated', ->
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      $('body').append '<div class="component-area--header" id="test-header"></div>'

      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')
        order: 1

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
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      $('body').append '<div class="component-area--header" id="test-header"></div>'

      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        targetPrefix: 'component-area'
        instance: new MockComponent {id: "instance-0"}
        target: $('.component-area--header')

    afterEach ->
      do activeInstanceDefinitionModel.dispose
      do $('.test-prefix--header').remove

    it 'should add a --has-components variation class to the component area
      ex: component-area--has-components if it holds components', ->

      $target = activeInstanceDefinitionModel.get 'target'
      assert.equal $target.children().length, 0

      do activeInstanceDefinitionModel._addInstanceInOrder
      assert.equal $target.children().length, 1

      do activeInstanceDefinitionModel._updateTargetPopulatedState

      assert $target.hasClass('component-area--has-components')


    it.only 'should remove the --has-components variation class to the component area
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
    it '', ->
      assert.equal true, false

  describe '_getInstanceArguments', ->
    it '', ->
      assert.equal true, false

  describe '_previousElement', ->
    activeInstanceDefinitionModel = undefined

    beforeEach ->
      activeInstanceDefinitionModel = new ActiveInstanceDefinitionModel
        id: 'my-active-instance-definition'
        componentClass: MockComponent
        instance: new MockComponent {id: "instance-1"}
        target: $('body')

      $('body').append '<div id="dummy1" class="dummy-elements" data-order="1"></div>'
      $('body').append '<div id="dummy2" class="dummy-elements" data-order="2"></div>'
      $('body').append '<div id="dummy3" class="some-other-element"></div>'
      $('body').append '<div id="dummy4" class="dummy-elements" data-order="3"></div>'
      $('body').append '<div id="dummy5" class="dummy-elements" data-order="4"></div>'
      $('body').append '<div id="dummy6" class="dummy-elements" data-order="8"></div>'

    afterEach ->
      do $('.dummy-elements').remove
      do $('.some-other-element').remove
      do activeInstanceDefinitionModel.dispose

    it 'should return previous element based on the data-order attribute', ->
      $startEl = $ '.dummy-elements[data-order="4"]'
      $targetEl = $ '.dummy-elements[data-order="3"]'

      $result = activeInstanceDefinitionModel._previousElement $startEl, $startEl.data('order')
      resultId = $result.attr 'id'
      targetId = $targetEl.attr 'id'

      assert.equal resultId, targetId

    it 'should find the previous element even though the order is not strictly sequential', ->
      $startEl = $ '.dummy-elements[data-order="8"]'
      $targetEl = $ '.dummy-elements[data-order="4"]'

      $result = activeInstanceDefinitionModel._previousElement $startEl, $startEl.data('order')
      resultId = $result.attr 'id'
      targetId = $targetEl.attr 'id'

      assert.equal resultId, targetId

    it 'should skip elements without a data-order attribute', ->
      $startEl = $ '.dummy-elements[data-order="3"]'
      $targetEl = $ '.dummy-elements[data-order="2"]'

      $result = activeInstanceDefinitionModel._previousElement $startEl, $startEl.data('order')
      resultId = $result.attr 'id'
      targetId = $targetEl.attr 'id'

      assert.equal resultId, targetId

    it 'should return undefined if there is $el.length is 0', ->
      $startEl = $ '.non-existing-element'
      $result = activeInstanceDefinitionModel._previousElement $startEl, $startEl.data('order')

      assert.equal $result, undefined

    it 'should return undefined if no previous element can be found', ->
      $startEl = $ '.dummy-elements[data-order="1"]'
      $result = activeInstanceDefinitionModel._previousElement $startEl, $startEl.data('order')

      assert.equal $result, undefined


  describe '_updateUrlParamsModel', ->
  describe '_onInstanceChange', ->
  describe '_onUrlParamsChange', ->
  describe '_onOrderChange', ->
  describe '_onTargetChange', ->
  describe '_onSerializedFilterChange', ->
  describe '_onAdd', ->
  describe '_onRemove', ->

