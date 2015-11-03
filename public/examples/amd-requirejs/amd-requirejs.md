## AMD example using requirejs

TODO: fix me

This is a small example of how you can let the componentManager require components using requirejs (amd).

To use compiled version uncomment the script tag in index.jade and run:

    node r.js -o build-vendors.js
    node r.js -o build.js

Components has to be required priror to initialization of the componentManager - no lazy loading yet :(
