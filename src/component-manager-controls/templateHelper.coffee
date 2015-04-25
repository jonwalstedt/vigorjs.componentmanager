templateHelper =
  storeComponentManager: (@componentManager) ->

  getMainTemplate: ->
    markup = """
    <button class='vigorjs-controls__toggle-controls'>Controls</button>

    <div class='vigorjs-controls__header'>
      <h1 class='vigorjs-controls__title'>Do you want to register, create, update or delete a component?</h1>
      <button class='vigorjs-controls__show-form-btn' data-target='register'>Register</button>
      <button class='vigorjs-controls__show-form-btn' data-target='create'>Create</button>
      <button class='vigorjs-controls__show-form-btn' data-target='update'>Update</button>
      <button class='vigorjs-controls__show-form-btn' data-target='delete'>Delete</button>
    </div>

    <div class='vigorjs-controls__forms'>
      <div class='vigorjs-controls__wrapper vigorjs-controls__register-wrapper' data-id='register'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__create-wrapper' data-id='create'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__update-wrapper' data-id='update'></div>
      <div class='vigorjs-controls__wrapper vigorjs-controls__delete-wrapper' data-id='delete'></div>
    </div>

    """
    return markup

  getCreateTemplate: (selectedComponent = undefined) ->
    components = templateHelper.getRegisteredComponents(selectedComponent)
    conditions = templateHelper.getRegisteredConditions()
    availableTargets = templateHelper.getTargets()
    appliedConditions = templateHelper.getAppliedCondition(selectedComponent)
    conditionsMarkup = ''
    appliedConditionsMarkup = ''

    if conditions
      conditionsMarkup = """
          <p>Available component conditions:</p>
          #{conditions}
      """

    if appliedConditions
      appliedConditionsMarkup = """
          <p>Already applied conditions:</p>
          #{appliedConditions}
      """

    markup = """
      <form class='vigorjs-controls__create'>
        <div class="vigorjs-controls__field">
          <label for='component-type'>Select component type</label>
          #{components}
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-id'>Instance id - a unique instance id</label>
          <input type='text' id='component-id' placeholder='id' name='id'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-url-pattern'>Backbone url pattern</label>
          <input type='text' id='component-url-pattern' placeholder='UrlPattern, ex: /article/:id' name='urlPattern'/>
        </div>

        <div class="vigorjs-controls__field">
          #{availableTargets}
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-order'>Instance order</label>
          <input type='text' id='component-order' placeholder='Order, ex: 10' name='order'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-reinstantiate'>Reinstantiate component on url param change?</label>
          <input type='checkbox' name='reInstantiateOnUrlParamChange'>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-filter'>Instance filter - a string that you can use to match against when filtering components</label>
          <input type='text' id='component-filter' placeholder='Filter' name='filter'/>
        </div>

        <div class="vigorjs-controls__field">
          #{conditionsMarkup}
        </div>

        <div class="vigorjs-controls__field">
          #{appliedConditionsMarkup}
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-condition'>Instance conditions</label>
          <input type='text' id='component-condition' placeholder='condition' name='condition'/>
        </div>

        <div class='vigorjs-controls__create-feedback'></div>
        <button type='button' class='vigorjs-controls__create-btn'>Create</button>
      </form>
    """
    return markup

  getRegisteredComponents: (selectedComponent) ->
    componentDefinitions = @componentManager.componentDefinitionsCollection.toJSON()
    if componentDefinitions.length > 0
      markup = '<select>'
      markup += "<option value='non-selected' selected='selected'>Select a component type</option>"
      for component in componentDefinitions
        selected = ''
        if component.componentId is selectedComponent
          selected = 'selected="selected"'
        markup += "<option value='#{component.componentId}' #{selected}>#{component.componentId}</option>"
      markup += '</select>'

      return markup

  getRegisteredConditions: ->
    conditions = @componentManager.conditions
    if not _.isEmpty(conditions)
      markup = ''
      for condition of conditions
        markup += "<span>#{condition} </span>"
      return markup

  getAppliedCondition: (selectedComponent) ->
    if selectedComponent
      componentDefinition = @componentManager.componentDefinitionsCollection.get({id: selectedComponent})

  getTargets: ->
    targetPrefix = @componentManager.instanceDefinitionsCollection.targetPrefix
    $targets = $ "[class^='#{targetPrefix}']"
    if $targets.length > 0
      markup = '<label for="vigorjs-controls__targets">Select a target for your component</label>'
      markup += '<select id="vigorjs-controls__targets" class="vigorjs-controls__targets">'
      markup += "<option value='non-selected' selected='selected'>Select a target</option>"
      for target in $targets
        $target = $ target
        targetClasses = $target.attr 'class'
        classSegments = targetClasses.split ' '
        classSegments = _.without classSegments, "#{targetPrefix}--has-component", targetPrefix
        target = {}

        for segment in classSegments
          if segment.indexOf(targetPrefix) > -1
            target.class = ".#{segment}"
            target.name = segment.replace("#{targetPrefix}--", '')

        markup += "<option value='#{$target.class}'>#{target.name}</option>"
      markup += '</select>'

