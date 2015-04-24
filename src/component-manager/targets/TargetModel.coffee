class TargetModel extends Backbone.Model

  defaults:
    targetName: undefined
    instanceDefinitionsArray: []

  validate: (attrs, options) ->
    unless attrs.targetName
      throw 'targetName cant be undefined'

    unless typeof attrs.targetName is 'string'
      throw 'targetName should be a string'

    unless /^.*[^ ].*$/.test(attrs.targetName)
      throw 'targetName can not be an empty string'

    unless attrs.instanceDefinitionsArray
      throw 'instanceDefinitionsArray cant be undefined'

    unless _.isArray attrs.instanceDefinitionsArray
      throw 'instanceDefinitionsArray must be an array'