templateHelper =
  storeComponentManager: (@componentManager) ->

  getRegisteredComponents: ->
    componentDefinitions = @componentManager.componentDefinitionsCollection.toJSON()
    if componentDefinitions.length > 0
      markup = '<select>'
      for component in componentDefinitions
        markup += "<option value='#{component.componentId}'>#{component.componentId}</option>"
      markup += '</select>'

      return markup

  getRegisteredRestrictions: ->
    restrictions = @componentManager.restrictions

    if not _.isEmpty(restrictions)
      markup = '<select>'
      for restriction of restrictions
        console.log restriction
        markup += "<option value='#{restriction}'>#{restriction}</option>"
      markup += '</select>'

      return markup

