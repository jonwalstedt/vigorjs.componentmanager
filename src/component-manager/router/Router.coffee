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
    origRoute = route
    if !_.isRegExp(route) then route = @_routeToRegExp(route)
    args = []
    if route.exec(fragment)
      args = _.compact @_extractParameters(route, fragment)
    args = @_getParamsObject origRoute, args
    return args

  _getParamsObject: (route, args) ->
    optionalParam = /\((.*?)\)/g
    namedParam = /(\(\?)?:\w+/g
    splatParam = /\*\w+/g
    params = {}

    optionalParams = route.match new RegExp(optionalParam)
    names = route.match new RegExp(namedParam)
    splats = route.match new RegExp(splatParam)

    storeNames = (matches, args) ->
      for name, i in matches
        name = name.replace(':', '')
                   .replace('(', '')
                   .replace(')', '')
                   .replace('*', '')

        params[name] = args[i]

    if optionalParams
      storeNames optionalParams, args

    if names
      storeNames names, args

    if splats
      storeNames splats, args

    return params

router = new Router()