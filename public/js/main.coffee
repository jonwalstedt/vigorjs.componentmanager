class App

  VIEWPORT_CUTOF: 200
  ACTIVE_LINK_CLASS: 'link--active'

  _isMenuOpen: false

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
    # @_debouncedOnScroll = _.debounce @_onScroll, 10
    @_debouncedSetActiveSectionFromScrollPosition = _.debounce @_setActiveSectionFromScrollPosition, 100
    if @$sidebar.length
      @origTop = @$sidebar.offset().top

    setTimeout =>
      hash = window.location.hash?.substring 1
      $target = $ "[name='#{hash}']"
      if $target.length
        @_scrollToTarget $target
    , 1000

    do @_updateActiveLinks

    @$window.on 'hashchange', @_updateActiveLinks
    # @$window.on 'scroll', @_debouncedOnScroll
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
    do @_closeMenu

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

  _scrollToTarget: ($target) =>
    @$body.stop().animate scrollTop: $target.offset().top, 1000

  _onLinkClick: (event) =>
    $currentTarget = $ event.currentTarget
    href = $currentTarget.attr('href').split('/').pop()
    if href.indexOf('#') > -1
      strippedHref = href.substring 1
      $target = $ "[name='#{strippedHref}']"
      if $target.length
        @_scrollToTarget $target
      do event.preventDefault

  # _onScroll: (event) =>
  #   scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  #   if @$sidebar.length
  #     if scrollTop > @origTop
  #       @$sidebarWrapper.height @$sidebar.height()
  #       @$contentWrapper.addClass 'sidebar--fixed'
  #     else
  #       @$sidebarWrapper.removeAttr 'style'
  #       @$contentWrapper.removeClass 'sidebar--fixed'

  _openMenu: =>
    @$menuToggle.addClass 'menu-toggle--active'
    @$contentWrapper.addClass 'sidebar--visible'
    @$menuToggle.find('.menu-icon').addClass 'close'
    @_isMenuOpen = true

  _closeMenu: =>
    @$menuToggle.removeClass 'menu-toggle--active'
    @$contentWrapper.removeClass 'sidebar--visible'
    @$menuToggle.find('.menu-icon').removeClass 'close'
    @_isMenuOpen = false

  _onMenuToggleClick: =>
    if @_isMenuOpen
      do @_closeMenu
    else
      do @_openMenu

window.app = new App()