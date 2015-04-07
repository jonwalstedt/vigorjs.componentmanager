class Router extends Backbone.Router

  getArguments: (route, fragment) ->
    if !_.isRegExp(route) then route = @_routeToRegExp(route)
    args = @_extractParameters(route, fragment)
    return _.compact(args)


