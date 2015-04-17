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
    # @_getParamsObject route
    if !_.isRegExp(route) then route = @_routeToRegExp(route)
    args = []
    if route.exec(fragment)
      args = _.compact @_extractParameters(route, fragment)
    return args

  # _getParamsObject: (route) ->
  #   optionalParam = /\((.*?)\)/g;
  #   namedParam    = /(\(\?)?:\w+/g;
  #   splatParam    = /\*\w+/g;
  #   escapeRegExp  = /[\-{}\[\]+?.,\\\^$|#\s]/g;

  #   r = route.replace(optionalParam, '(?:$1)?')
  #                # .replace(namedParam, (match, optional) ->
  #                #    if optional
  #                #      return match
  #                #    else
  #                #      return '([^/?]+)'
  #                # )
  #                # .replace(splatParam, '([^?]*?)')

  #   console.log route.match new RegExp(r)
  #   # console.log 'route: ', new RegEx  '^' + route + '(?:\\?([\\s\\S]*))?$'
  #   # return new RegExp '^' + route + '(?:\\?([\\s\\S]*))?$'

