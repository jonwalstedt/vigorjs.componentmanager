define(function (require) {

  'use strict';

  var TimeModel,
      Backbone = require('backbone');

  TimeModel = Backbone.Model.extend({
    defaults: {
      selectedTime: 1
    },

    timeMapp: {
      1: 'one',
      2: 'two',
      3: 'three',
      4: 'four',
      5: 'five',
      6: 'six',
      7: 'seven',
      8: 'eight',
      9: 'nine'
    },

    getSelectedTime: function () {
      var time = this.get('selectedTime'),
          timeObj = {
            time: time
          };

      if (time == 1) {
        timeObj.timeStr = this.timeMapp[time] + ' day';
      } else if (time > 1 && time < 10) {
        timeObj.timeStr = this.timeMapp[time] + ' days';
      } else {
        timeObj.timeStr = time + ' days';
      }

      return timeObj;
    }

  });

  return TimeModel;

});