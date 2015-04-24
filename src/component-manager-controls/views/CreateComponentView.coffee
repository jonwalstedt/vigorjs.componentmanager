class CreateComponentView extends Backbone.View

  className: 'vigorjs-controls__create-component'
  # events:
  #   'click .vigorjs-controls__register-btn': '_onRegister'

  componentManager: undefined
  $feedback: undefined

  initialize: (attributes) ->
    @componentManager = attributes.componentManager
    @listenTo @componentManager.componentDefinitionsCollection, 'change add remove', @_onComponentDefinitionChange

  render: ->
    do @$el.empty
    @$el.html @getTemplate()
    @$feedback = $ '.vigorjs-controls__create-feedback', @el
    return @

  getTemplate: ->
    componentDefinitions = @componentManager.componentDefinitionsCollection.toJSON()

    components = templateHelper.getRegisteredComponents()
    restrictions = templateHelper.getRegisteredRestrictions()
    restrictionsMarkup = ''
    if restrictions
      retstrictionsMarkup = """
        <div class="vigorjs-controls__field">
          <label for='component-type'>Select component restriction</label>
          #{restrictions}
        </div>
      """

    markup = """
      <form class='vigorjs-controls__create'>
        <div class="vigorjs-controls__field">
          <label for='component-type'>Select component type</label>
          #{components}
        </div>

        #{restrictionsMarkup}

        <div class="vigorjs-controls__field">
          <label for='component-id'>Instance id - a unique instance id</label>
          <input type='text' id='component-id' placeholder='id' name='id'/>
        </div>

        <div class="vigorjs-controls__field">
          <label for='component-filter'>Instance filter - a string that you can use to match against when filtering components</label>
          <input type='text' id='component-filter' placeholder='Filter' name='filter'/>
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

  _onComponentDefinitionChange: =>
    do @render