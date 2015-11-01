var browserify = require('browserify'),
    handlebars = require('browserify-handlebars'),
    b = browserify('./main.js');

b.transform(handlebars);
b.require(__dirname + '/components/menu-component/', {expose: 'components/menu-component/'});
b.bundle().pipe(process.stdout);

// run watchify main.js -o 'node bundler.js > bundle.js' -v

