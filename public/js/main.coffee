class App

  VIEWPORT_CUTOF: 200

  constructor: ->
    @$window = $ window
    @$body = $ 'html, body'
    @$links = $ 'a'
    @$contentWrapper = $ '.content-wrapper'
    @$sidebarWrapper = $ '.sidebar-wrapper'
    @$sidebar = $ '.sidebar'
    @$sectionHeaders = $ '.sub-section > h3 > a'
    @origTop = @$sidebar.offset().top or 0
    @_debouncedOnScroll = _.debounce @_onScroll, 10
    @_debouncedSetActiveSectionFromScrollPosition = _.debounce @_setActiveSectionFromScrollPosition, 100
    do @_updateActiveLinks

    @$window.on 'hashchange', @_updateActiveLinks
    @$window.on 'scroll', @_debouncedOnScroll
    @$window.on 'scroll', @_debouncedSetActiveSectionFromScrollPosition
    @$window.trigger 'scroll'

    $('.sidebar a, .docs .content a').on 'click', @_onLinkClick

    do hljs.initHighlightingOnLoad

  _updateActiveLinks: =>
    hash = window.location.hash
    pathname = window.location.pathname
    $activeLinks = $ "[href='#{hash}'], [href='#{pathname}']"
    @$links.removeClass 'link--active'
    $activeLinks.addClass 'link--active'

  _onLinkClick: (event) =>
    $currentTarget = $ event.currentTarget
    href = $currentTarget.attr 'href'
    href = href.split('/').pop()
    if href.indexOf('#') > -1
      strippedHref = href.substring 1
      $target = $ "[name='#{strippedHref}']"
      if $target.length
        @$body.stop().animate scrollTop: $target.offset().top, 1000, =>
          window.location.hash = href

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

window.app = new App()