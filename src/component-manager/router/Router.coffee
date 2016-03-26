class Router extends Backbone.Router

  getArguments: (urlPatterns, url) ->
    unless _.isArray(urlPatterns)
      urlPatterns = [urlPatterns]

    args = []

    for urlPattern in urlPatterns
      match = @doesUrlPatternMatch urlPattern, url

      if match
        paramsObject = @_getArgumentsFromUrl urlPattern, url
        paramsObject._id = urlPattern
        paramsObject.url = url
      else
        paramsObject =
          _id: urlPattern
          url: url

      args.push paramsObject
    return args

  routeToRegExp: (urlPattern) ->
    @_routeToRegExp urlPattern

  doesUrlPatternMatch: (urlPattern, url) ->
    return true if urlPattern is 'global'
    routeRegEx = @routeToRegExp urlPattern
    return routeRegEx.test url

  _getArgumentsFromUrl: (urlPattern, url) ->
    origUrlPattern = urlPattern

    if !_.isRegExp(urlPattern)
      urlPattern = @_routeToRegExp(urlPattern)

    if urlPattern.exec(url)
      extractedParams = _.compact @_extractParameters(urlPattern, url)

    return @_getParamsObject(origUrlPattern, extractedParams)

  _getParamsObject: (urlPattern, extractedParams) ->
    return extractedParams unless _.isString(urlPattern)
    optionalParam = /\((.*?)\)/g
    namedParam = /(\(\?)?:\w+/g
    splatParam = /\*\w+/g
    params = {}

    optionalParams = urlPattern.match new RegExp(optionalParam)
    names = urlPattern.match new RegExp(namedParam)
    splats = urlPattern.match new RegExp(splatParam)

    storeNames = (matches, args) ->
      for name, i in matches
        name = name.replace /([^a-z0-9]+)/gi, ''
        params[name] = args[i]

    if optionalParams
      storeNames optionalParams, extractedParams

    if names
      storeNames names, extractedParams

    if splats
      storeNames splats, extractedParams

    return params

router = new Router()