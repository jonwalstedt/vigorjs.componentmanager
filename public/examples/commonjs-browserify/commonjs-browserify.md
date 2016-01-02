## COMMONJS example using browserify

This is a small example of how you can let the componentManager require components using browserify (CommonJS).

To play around with example first run npm install and then install browserify and watchify globaly with npm install -g browserify and npm install -g watchify, you may have to use sudo to install them globaly.

To build bundle run:


<div class="hljs javascript">
  <pre>node bundler.js > bundle.js</pre>
</div>

To build vendor bundle run:

<div class="hljs javascript">
  <pre>node bundler.js vendor > bundle.vendors.js</pre>
</div>

to build and watch run:

<div class="hljs javascript">
  <pre>watchify main.js -o 'node bundler.js > bundle.js' -v</pre>
</div>
