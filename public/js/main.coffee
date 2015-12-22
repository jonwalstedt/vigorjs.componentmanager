class App
  constructor: (@$contentWrapper, @$sidebar) ->
    @$body = $ 'html, body'
    @$contentWrapper = $ '.content-wrapper'
    @$sidebar = $ '.sidebar'

    if @$sidebar.length
      @$sidebarLinks = @$sidebar.find 'a'
      @$sidebarWrapper = $ '.sidebar-wrapper'
      @origTop = @$sidebar.offset().top
      hash = window.location.hash

      if hash
        $currentTarget = $ "[href='#{hash}']", @$sidebar
        @_updateSidebarLinkActiveState $currentTarget

      $(window).on 'scroll', @_onScroll
      $(window).trigger 'scroll'
      $('a').on 'click', @_onLinkClick

    do hljs.initHighlightingOnLoad

  _updateSidebarLinkActiveState: ($link) ->
    @$sidebarLinks.removeClass 'sidebar__link--active'
    $link.addClass 'sidebar__link--active'

  _onHashUpdate: (event) =>
    hash = window.location.hash
    strippedHash = hash.substring 1
    $target = $ "[name='#{strippedHash}']"
    @$body.stop().animate scrollTop: $target.offset().top, 1000

  _onLinkClick: (event) =>
    $currentTarget = $ event.currentTarget
    href = $currentTarget.attr 'href'
    if href.indexOf('#') > -1
      @_updateSidebarLinkActiveState $currentTarget
      strippedHref = href.substring 1
      $target = $ "[name='#{strippedHref}']"
      if $target.length
        @$body.stop().animate scrollTop: $target.offset().top, 1000, ->
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