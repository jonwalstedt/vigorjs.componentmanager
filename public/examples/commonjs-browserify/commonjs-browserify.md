## COMMONJS example using browserify

This is a small example of how you can let the componentManager require components using browserify (commonjs).

To play around with example first run npm install and then install browserify and watchify globaly with npm install -g browserify and npm install -g watchify, you may have to use sudo to install them globaly.

To build bundle run:

    node bundler.js > bundle.js

to build and watch run:

    watchify main.js -o 'node bundler.js > bundle.js' -v
