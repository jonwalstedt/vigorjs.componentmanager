router = new Router()

class LayoutCollection extends Backbone.Collection

  TARGET_PREFIX = 'component-area'

  model: LayoutModel

  parse: (response, options) ->
    layoutsArray = []
    for targetName, layouts of response
      for layout in layouts
        layout.targetName = "#{TARGET_PREFIX}-#{targetName}"
        layoutsArray.push layout

    return layoutsArray

  getComponents: (filterOptions) ->
    components = @models
    if filterOptions.route
      components = @filterComponentsByUrl components, filterOptions.route

    return components

  getComponentsByUrl: (route) ->
    return @filterComponentsByUrl @models, route

  filterComponentsByUrl: (components, route) ->
    components = _.filter components, (component) =>
      urlPattern = component.get 'urlPattern'
      if urlPattern
        routeRegEx = router._routeToRegExp component.get('urlPattern')
        return routeRegEx.test route
    return components


