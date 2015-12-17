class BaseInstanceCollection extends BaseCollection

  ERROR:
    UNKNOWN_INSTANCE_DEFINITION: 'Unknown instanceDefinition, are you referencing correct instanceId?'

  model: InstanceDefinitionModel

  initialize: ->
    @on 'reset', @_onReset
    super

  getInstanceDefinition: (instanceId) ->
    instanceDefinition = @get instanceId
    unless instanceDefinition
      throw @ERROR.UNKNOWN_INSTANCE_DEFINITION
    return instanceDefinition

  _onReset: (collection, options) ->
    _.invoke options.previousModels, 'dispose'
