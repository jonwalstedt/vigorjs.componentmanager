class Router extends Backbone.Router

  getArguments: (urls, fragment) ->
    if _.isArray(urls)
      args = []
      for url in urls
        args = @_getArgumentsFromUrl url, fragment
      return args
    else
      @_getArgumentsFromUrl urls, fragment

  _getArgumentsFromUrl: (url, fragment) ->
    origUrl = url
    if !_.isRegExp(url) then url = @_routeToRegExp(url)
    args = []
    if url.exec(fragment)
      args = _.compact @_extractParameters(url, fragment)
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