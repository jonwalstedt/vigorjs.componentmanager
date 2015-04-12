class Router extends Backbone.Router

  getArguments: (routes, fragment) ->
    if _.isArray(routes)
      args = []
      for route in routes
        args = @_getArgumentsFromRoute route, fragment
      return args
    else
      @_getArgumentsFromRoute routes, fragment

  _getArgumentsFromRoute: (route, fragment) ->
    if !_.isRegExp(route) then route = @_routeToRegExp(route)
    args = []
    if route.exec(fragment)
      args = _.compact @_extractParameters(route, fragment)
    return args
