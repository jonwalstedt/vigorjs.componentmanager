define(function (require) {

  /*
   * Math augmentation.
   * modified version of Matthew Wagerfield @mwagerfield math class
   * https://github.com/wagerfield/danbo/blob/master/assets/scripts/coffee/core/Math.coffee
  */

  return {
    PI2: Math.PI * 2,
    PIH: Math.PI / 2,
    PIQ: Math.PI / 4,
    PIR: 180 / Math.PI,
    PID: Math.PI / 180,

    percentToDegrees: function (percent) {
      return percent * 3.6;
    },
    /*
     * Converts radians to degrees.
     * @param {number} radians The radians to convert.
     * @return {number} The value in degrees.
     */
    radiansToDegrees: function (radians) {
      return radians * this.PIR;
    },


    /*
     * Converts degrees to radians.
     * @param {number} degrees The degrees to convert.
     * @return {number} The value in radians.
     */
    degreesToRadians: function (degrees) {
      return degrees * this.PID;
    },


    /*
     * Normalises a given value.
     * @param {number} value The value to normalise.
     * @param {number} min The minimum value in the range.
     * @param {number} max The maximum value in the range.
     * @return {value} The normalised number.
     */
    normalise: function (value, min, max) {
      if (min == null) {
        min = 0;
      }
      if (max == null) {
        max = 1;
      }
      return (value - min) / (max - min);
    },

    normalize: this.normalise,

    /*
     * Interpolates between two values by a given multiplier.
     * @param {number} value The multiplier value.
     * @param {number} min The minimum value in the range.
     * @param {number} max The maximum value in the range.
     * @return {value} The interpolated number.
     */
    interpolate: function (value, min, max) {
      return min + (max - min) * value;
    },


    /*
     * Maps a value within a certain range to another range.
     * @param {number} value The value to map.
     * @param {number} min1 The minimum value in the first range.
     * @param {number} max1 The maximum value in the first range.
     * @param {number} min2 The minimum value in the second range.
     * @param {number} max2 The maximum value in the second range.
     * @return {value} The mapped number.
     */
    map: function (value, min1, max1, min2, max2) {
      return this.interpolate(this.normalise(value, min1, max1), min2, max2);
    },


    /*
     * Clamps a number within a specified range.
     * @param {number} value The value to clamp.
     * @param {number} min The minimum value.
     * @param {number} max The maximum value.
     * @return {value} The clamped number.
     */
    clamp: function (value, min, max) {
      value = Math.max(value, min);
      value = Math.min(value, max);
      return value;
    },


    /*
     * Return the sign of the value.
     * @param {number} value The number.
     * @return {value} 1 or -1 depending on the sign.
     */
    sign: function (value) {
      if (value >= 0) {
        return 1;
      } else {
        return -1;
      }
    },


    /*
     * Generates a random number within a specified range.
     * @param {number} min Minimum number in the range.
     * @param {number} max Maximum number in the range.
     * @param {boolean} round Whether or not to round the generated value.
     * @return {number} Random number within the specified range.
     */
    randomInRange: function (min, max, round) {
      var value;
      if (round == null) {
        round = false;
      }
      value = this.map(Math.random(), 0, 1, min, max);
      if (round) {
        value = Math.round(value);
      }
      return value;
    },


    /*
     * Projects a geographic coordinate into a 3D vertex.
     * @param {number} x The horizontal component.
     * @param {number} y The vertical component.
     * @param {number} radius The length of the vector.
     * @return {THREE.Vector3} Projected vector coordinate.
     */
    project: function (x, y, radius) {
      var cosX, cosY, sinX, sinY, z;
      if (radius == null) {
        radius = 1;
      }
      x = this.degreesToRadians(x);
      y = this.degreesToRadians(y);
      sinX = Math.sin(x);
      cosX = Math.cos(x);
      sinY = Math.sin(y);
      cosY = Math.cos(y);
      x = -radius * cosY * cosX;
      y = radius * sinY;
      z = radius * cosY * sinX;
      return [x, y, z];
    },

    formatBytes: function (bytes, decimals) {
      var k = 1000,
          dm = decimals + 1 || 3,
          sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
          i = Math.floor(Math.log(bytes) / Math.log(k));

      if (bytes == 0) return '0 Byte';
      return {
        value: +(bytes / Math.pow(k, i)).toPrecision(dm),
        suffix: sizes[i],
        string: (bytes / Math.pow(k, i)).toPrecision(dm) + ' ' + sizes[i]
      }
    }

  }

});
