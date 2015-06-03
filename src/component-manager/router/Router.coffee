class Router extends Backbone.Router

  getArguments: (urlPatterns, url) ->
    unless _.isArray(urlPatterns)
      urlPatterns = [urlPatterns]

    args = []

    for urlPattern in urlPatterns
      routeRegEx = @routeToRegExp urlPattern
      match = routeRegEx.test url

      if match
        params = @_getArgumentsFromUrl urlPattern, url
        params.url = url
        args.push params

    return args

  routeToRegExp: (urlPattern) ->
    @_routeToRegExp urlPattern

  _getArgumentsFromUrl: (urlPattern, url) ->
    origUrl = urlPattern
    if !_.isRegExp(urlPattern) then urlPattern = @_routeToRegExp(urlPattern)
    args = []
    if urlPattern.exec(url)
      args = _.compact @_extractParameters(urlPattern, url)
    args = @_getParamsObject origUrl, args
    return args

  _getParamsObject: (url, args) ->
    optionalParam = /\((.*?)\)/g
    namedParam = /(\(\?)?:\w+/g
    splatParam = /\*\w+/g
    params = {}

    optionalParams = url.match new RegExp(optionalParam)
    names = url.match new RegExp(namedParam)
    splats = url.match new RegExp(splatParam)

    storeNames = (matches, args) ->
      for name, i in matches
        name = name.replace(':', '')
                   .replace('(', '')
                   .replace(')', '')
                   .replace('*', '')
                   .replace('/', '')

        params[name] = args[i]

    if optionalParams
      storeNames optionalParams, args

    if names
      storeNames names, args

    if splats
      storeNames splats, args

    return params

router = new Router()