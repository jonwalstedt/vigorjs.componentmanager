class App
  constructor: ->
    @$window = $ window
    @$body = $ 'html, body'
    @$links = $ 'a'
    @$contentWrapper = $ '.content-wrapper'
    @$sidebarWrapper = $ '.sidebar-wrapper'
    @$sidebar = $ '.sidebar'
    do @_updateActiveLinks

    @$window.on 'hashchange', @_updateActiveLinks

    if @$sidebar.length
      @origTop = @$sidebar.offset().top

      $(window).on 'scroll', @_onScroll
      $(window).trigger 'scroll'
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
    if scrollTop > @origTop
      @$sidebarWrapper.height @$sidebar.height()
      @$contentWrapper.addClass 'sidebar--fixed'
    else
      @$sidebarWrapper.removeAttr 'style'
      @$contentWrapper.removeClass 'sidebar--fixed'

new App()