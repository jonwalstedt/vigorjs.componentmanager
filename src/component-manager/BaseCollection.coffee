# More or less duplicated logic from Vigor.Repositories - this is done to avoid a
# hard dependency to the Vigorjs lib
class BaseCollection extends Backbone.Collection

  THROTTLED_DIFF: 'throttled_diff'
  THROTTLED_ADD: 'throttled_add'
  THROTTLED_CHANGE: 'throttled_change'
  THROTTLED_REMOVE: 'throttled_remove'

  _throttledAddedModels: undefined
  _throttledChangedModels: undefined
  _throttledRemovedModels: undefined
  _throttledTriggerUpdates: undefined
  _throttleDelay: 50

  initialize: ->
    @_throttledAddedModels = {}
    @_throttledChangedModels = {}
    @_throttledRemovedModels = {}

    @_throttledTriggerUpdates = _.throttle @_triggerUpdates, @_throttleDelay, leading: no

    do @addThrottledListeners
    super

  addThrottledListeners: ->
    @on 'all', @_onAll

  getByIds: (ids) ->
    models = []
    for id in ids
      models.push @get id
    return models

  isEmpty: ->
    return @models.length <= 0

  _onAll: (event, args...) ->
    switch event
      when 'add' then @_onAdd.apply(@, args)
      when 'change' then @_onChange.apply(@, args)
      when 'remove' then @_onRemove.apply(@, args)

    do @_throttledTriggerUpdates

  _onAdd: (model) =>
    @_throttledAddedModels[model.id] = model

  _onChange: (model) =>
    @_throttledChangedModels[model.id] = model

  _onRemove: (model) =>
    @_throttledRemovedModels[model.id] = model

  _throttledAdd: ->
    event = BaseCollection::THROTTLED_ADD
    models = _.values @_throttledAddedModels
    @_throttledAddedModels = {}
    if models.length > 0
      @trigger event, models, event
    return models

  _throttledChange: ->
    event = BaseCollection::THROTTLED_CHANGE
    models = _.values @_throttledChangedModels
    @_throttledChangedModels = {}
    if models.length > 0
      @trigger event, models, event
    return models

  _throttledRemove: ->
    event = BaseCollection::THROTTLED_REMOVE
    models = _.values @_throttledRemovedModels
    @_throttledRemovedModels = {}
    if models.length > 0
      @trigger event, models, event
    return models

  _throttledDiff: (added, changed, removed) ->
    event = BaseCollection::THROTTLED_DIFF
    if  added.length or \
        changed.length or \
        removed.length

      added = _.difference(added, removed)
      consolidated = _.uniq added.concat(changed)

      models =
        added: added
        changed: changed
        removed: removed
        consolidated: consolidated

      @trigger event, models, event

  _triggerUpdates: =>
    @_throttledDiff @_throttledAdd(), @_throttledChange(), @_throttledRemove()

