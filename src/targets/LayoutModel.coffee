class LayoutModel extends Backbone.Model

  defaults:
    componentId: undefined
    order: undefined
    filter: undefined
    urlPattern: undefined
    args: undefined

  # validate: (attrs, options) ->
  #   console.log 'TargetsCollection:validate', attrs