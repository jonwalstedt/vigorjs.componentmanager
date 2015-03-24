class ComponentDefinitionsCollection extends Backbone.Collection

  model: ComponentDefinitionModel

  initialize: ->
    super

  parse: (response, options) ->
    console.log 'ComponentDefinitionsCollection:parse', response
    return response