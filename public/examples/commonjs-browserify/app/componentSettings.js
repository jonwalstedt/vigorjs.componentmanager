var componentSettings = {
  components: [{
    id: 'menu-component',
    src: 'components/menu-component/',
  }],
  targets: {
    main: [
      {
        id: 'menu-instance',
        componentId: 'menu-component',
        urlPattern: 'add-components'
      }
    ]
  }
}

module.exports = componentSettings;
