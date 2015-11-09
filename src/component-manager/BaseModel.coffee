class BaseModel extends Backbone.Model

  getCustomProperties: (ignorePropertiesWithUndefinedValues = true) ->
    blackListedKeys = _.keys @defaults
    customProperties = _.omit @toJSON(), blackListedKeys

    if ignorePropertiesWithUndefinedValues
      for key, val of customProperties
        if customProperties.hasOwnProperty(key) and customProperties[key] is undefined
          delete customProperties[key]

    return customProperties