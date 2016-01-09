var browserify = require('browserify'),
    handlebars = require('browserify-handlebars'),
    externals = [
      {require: 'jquery', expose: 'jquery'},
      {require: 'backbone', expose: 'backbone'},
      {require: 'underscore', expose: 'underscore'},
      {require: 'handlebars', expose: 'handlebars'},
      {require: 'handlebars/runtime', expose: 'handlebars/runtime'},
    ],
    components = [
      {require: 'vigorjs.componentmanager', expose: 'vigorjs.componentmanager'},
      {require: __dirname + '/components/menu-component/', expose: 'components/menu-component'}
    ],
    options = {
      entries: ['./main.js'],
      extensions: ['.js', '.html'],
      fullPaths: false,
      packageCache: {},
      cache: {}
    },
    vendorOptions = {
      extensions: ['.js', '.html'],
      fullPaths: false,
      packageCache: {},
      cache: {}
    };

function bundle (vendor) {
  var b,
      vendorBuild = !!vendor;

  if (vendorBuild) {
    b = browserify(vendorOptions);
  } else {
    b = browserify(options);
  }

  externals.forEach(function (external) {
    if (vendorBuild) {
      if (external.expose) {
        b.require(external.require, {expose: external.expose});
      } else {
        b.require(external.require);
      }
    } else {
      if (external.expose) {
        b.external(external.require, {expose: external.expose});
      } else {
        b.external(external.require);
      }
    }
  });

  if (!vendorBuild) {
    components.forEach(function (component) {
      b.require(component.require, {expose: component.expose});
    });
  }

  b.transform(handlebars);
  return b.bundle();
}

bundle(process.argv[2]).pipe(process.stdout);

// run watchify main.js -o 'node bundler.js > bundle.js' -v

