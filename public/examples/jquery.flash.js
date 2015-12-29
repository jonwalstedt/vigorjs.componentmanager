$.fn.flash = function(duration, iterations) {
  duration = duration || 1000; // Default to 1 second
  iterations = iterations || 1; // Default to 1 iteration
  var iterationDuration = Math.floor(duration / iterations);

  for (var i = 0; i < iterations; i++) {
      this.fadeOut(iterationDuration).fadeIn(iterationDuration);
  }
  return this;
}
