class TargetsCollection extends Backbone.Collection

  model: TargetModel

  initialize: ->
    super

  parse: (response, options) ->
    console.log 'TargetsCollection:parse', response
    return response