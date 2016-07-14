class BaseModel extends Backbone.Model

  parse: (data) ->
    if data.vcmArgumentFields? and not data.vcmArgumentFieldValues?
      data.vcmArgumentFieldValues = {}
      for field in data.vcmArgumentFields
        data.vcmArgumentFieldValues[field.id] = field.default
    return data

  getArgs: ->
    args = @get('args') or {}
    vcmArgs = @get('vcmArgumentFieldValues') or {}
    return _.extend {}, args, vcmArgs

  getCustomProperties: (ignorePropertiesWithUndefinedValues = true) ->
    blackListedKeys = _.keys @defaults
    customProperties = _.omit @toJSON(), blackListedKeys

    if ignorePropertiesWithUndefinedValues
      for key, val of customProperties
        if customProperties.hasOwnProperty(key) and customProperties[key] is undefined
          delete customProperties[key]

    return customProperties

  # noop
  dispose: ->