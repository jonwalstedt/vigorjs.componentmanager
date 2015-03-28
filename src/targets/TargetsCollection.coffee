class TargetsCollection extends Backbone.Collection

  TARGET_PREFIX = 'component-area'

  model: TargetModel

  parse: (response, options) ->
    targets = []

    for targetName, layouts of response
      layoutsArray = []

      for layout in layouts
        layoutModel = new LayoutModel layout
        layoutsArray.push layoutModel

      targets.push
        targetName: "#{TARGET_PREFIX}-#{targetName}"
        layoutsArray: layoutsArray

    return targets
