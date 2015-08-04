assert = require 'assert'
Vigor = require '../../../dist/vigor.componentmanager'

__testOnly = Vigor.ComponentManager.__testOnly

ActiveInstancesCollection = __testOnly.ActiveInstancesCollection

class DummyComponent
  $el: undefined
  el: undefined
  render: ->
    @$el = $ '<div class="dummy-component"></div>'
    @el = @$el.get 0
    return @

dummyInstanceDefinitionObj =
  id: 'dummy'
  componentId: 'my-component'
  instance: new DummyComponent()
  targetName: 'main'

describe 'ActiveInstancesCollection', ->
  activeInstancesCollection = undefined

  beforeEach ->
    activeInstancesCollection = new ActiveInstancesCollection()
    activeInstancesCollection.add dummyInstanceDefinitionObj

  describe 'getStrays', ->
    it 'should return an array of models where instances are not attached to the dom', ->
      instance = activeInstancesCollection.get('dummy').get('instance')

      $('body').append '<div class="wrapper"></div>'
      $('.wrapper').append instance.render().$el

      strays = activeInstancesCollection.getStrays()
      assert.equal strays.length, 0

      $('.wrapper').remove()

      strays = activeInstancesCollection.getStrays()

      assert.equal _.isArray(strays), true
      assert.equal strays.length, 1
      assert.equal strays[0].get('id'), 'dummy'
      assert.equal $('.dummy-component').length, 0

    it 'should return an empty array when no stray instances are found', ->
      instance = activeInstancesCollection.get('dummy').get('instance')
      $('body').append instance.render().$el

      assert.equal $('.dummy-component').length, 1
      strays = activeInstancesCollection.getStrays()
