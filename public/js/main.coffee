class App

  VIEWPORT_CUTOF: 200
  ACTIVE_LINK_CLASS: 'link--active'

  constructor: ->
    @$window = $ window
    @$body = $ 'html, body'
    @$links = $ 'a'
    @$contentWrapper = $ '.content-wrapper'
    @$sidebarWrapper = $ '.sidebar-wrapper'
    @$menuToggle = $ '.menu-toggle'
    @$sidebar = $ '.sidebar'
    @$sectionHeaders = $ '.sub-section > h3 > a'
    @origTop = 0
    @_debouncedOnScroll = _.debounce @_onScroll, 10
    @_debouncedSetActiveSectionFromScrollPosition = _.debounce @_setActiveSectionFromScrollPosition, 100
    if @$sidebar.length
      @origTop = @$sidebar.offset().top
    do @_updateActiveLinks

    @$window.on 'hashchange', @_updateActiveLinks
    @$window.on 'scroll', @_debouncedOnScroll
    @$window.on 'scroll', @_debouncedSetActiveSectionFromScrollPosition
    @$window.trigger 'scroll'
    @$menuToggle.on 'click', @_onMenuToggleClick

    $('.sidebar a, .docs .content a').on 'click', @_onLinkClick

    do hljs.initHighlightingOnLoad

  _updateActiveLinks: =>
    hash = window.location.hash
    pathname = window.location.pathname
    $activeLinks = $ "[href='#{hash}'], [href='#{pathname}']"
    @$links.removeClass @ACTIVE_LINK_CLASS
    $activeLinks.addClass @ACTIVE_LINK_CLASS

  _setActiveSectionFromScrollPosition: =>
    for el in @$sectionHeaders
      $el = $ el
      if @_isElementInTopOfViewport(el)
        hash = $el.attr 'name'
        $el.removeAttr 'name'
        window.location.hash = hash
        $el.attr 'name', hash

  _isElementInTopOfViewport: (el) ->
    if typeof jQuery is "function" and el instanceof jQuery
      el = el[0]

    rect = el.getBoundingClientRect()

    return (
      rect.top >= 0 and
      rect.left >= 0 and
      rect.bottom <= @VIEWPORT_CUTOF and
      rect.right <= $(window).width()
    )

  _onLinkClick: (event) =>
    $currentTarget = $ event.currentTarget
    href = $currentTarget.attr('href').split('/').pop()
    if href.indexOf('#') > -1
      strippedHref = href.substring 1
      $target = $ "[name='#{strippedHref}']"
      if $target.length
        @$body.stop().animate scrollTop: $target.offset().top, 1000
      do event.preventDefault

  _onScroll: (event) =>
    scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    if @$sidebar.length
      if scrollTop > @origTop
        @$sidebarWrapper.height @$sidebar.height()
        @$contentWrapper.addClass 'sidebar--fixed'
      else
        @$sidebarWrapper.removeAttr 'style'
        @$contentWrapper.removeClass 'sidebar--fixed'

  _onMenuToggleClick: =>
    @$menuToggle.toggleClass 'menu-toggle--active'
    @$contentWrapper.toggleClass 'sidebar--visible'


window.app = new App()