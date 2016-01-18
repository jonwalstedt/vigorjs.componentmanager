define(function (require) {

  'use strict';

  var ArcsCollection,
      MathUtil = require('utils/MathUtil'),
      ArcModel = require('./ArcModel'),
      Backbone = require('backbone');

  ArcsCollection = Backbone.Collection.extend({
    model: ArcModel,

    parse: function (arcs) {
      var parsedArcs = [];
      for (var i = 0; i < arcs.length; i++) {
        var arc = arcs[i],
            parsedArc = {
              id: arc.id,
              limit: arc.limit,
              limitSuffix: arc.limitSuffix,
              usedSuffix: arc.usedSuffix,
              targetPercent: arc.percent,
              targetUsed: arc.used,
              targetAngle: MathUtil.degreesToRadians(MathUtil.percentToDegrees(arc.percent))
            }
        parsedArcs.push(parsedArc);
      };
      return parsedArcs;
    }
  })

  return ArcsCollection;
});
