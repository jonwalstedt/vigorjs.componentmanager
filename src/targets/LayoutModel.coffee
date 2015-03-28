class LayoutModel extends Backbone.Model

  defaults:
    componentId: undefined
    order: undefined
    filter: undefined
    args: undefined

  validate: (attrs, options) ->
    console.log 'TargetsCollection:validate', attrs