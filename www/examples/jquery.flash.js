$.fn.flash = function(duration, iterations, opacity) {
  duration = duration || 1000; // Default to 1 second
  iterations = iterations || 1; // Default to 1 iteration
  opacity = opacity || 0.5; // Default to 0.5 opacity
  var iterationDuration = Math.floor(duration / iterations);

  for (var i = 0; i < iterations; i++) {
      this.fadeTo(iterationDuration, opacity).fadeTo(iterationDuration, 1);
  }
  return this;
}
