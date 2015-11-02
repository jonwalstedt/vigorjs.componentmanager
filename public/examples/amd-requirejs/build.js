({
  baseUrl: "./",
  paths: {
    requireLib: 'lib/require',
    jquery: 'lib/jquery.min',
    underscore: 'lib/underscore.min',
    backbone: 'lib/backbone',
    Handlebars: 'lib/handlebars',
    text: 'lib/text',
    hbars: 'lib/hbars',
    vigor: '../../js/vigor.componentmanager',
    app: 'app',
    components: 'components'
  },
  packages: [
    {name: 'components/menu', location: 'components/menu-component'}
  ],
  name: "main",
  out: "main-built.js",
  include: ["requireLib"]
})