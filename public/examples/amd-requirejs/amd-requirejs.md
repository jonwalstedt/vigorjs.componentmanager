## AMD example using requirejs

This is a small example of how you can let the componentManager require components using requirejs (amd).

The componentManager allows you to require components on demand (asynchronously) if you are using and AMD loader like requirejs.

Of course you can compile the project down to a single file and have all components batched together and loaded with the rest of the application to avoid unnecessary requests.

To try out the compiled version uncomment the script tag in index.jade and run:

<div class="hljs javascript">
  <pre>node r.js -o build-vendors.js
node r.js -o build.js</pre>
</div>

