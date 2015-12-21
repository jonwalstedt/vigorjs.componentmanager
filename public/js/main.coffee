class App
  constructor: (@$contentWrapper, @$sidebar) ->
    @$body = $ 'html, body'
    @$contentWrapper = $ '.content-wrapper'
    @$sidebar = $ '.sidebar'
    @$sidebarWrapper = $ '.sidebar-wrapper'
    @origTop = @$sidebar.offset().top

    $(window).on 'scroll', @_onScroll
    $(window).trigger 'scroll'
    @$sidebar.find('a').on 'click', @_onAnchorClick

    do hljs.initHighlightingOnLoad

  _onAnchorClick: (event) =>
    $currentTarget = $ event.currentTarget
    href = $currentTarget.attr('href').substring 1
    $target = $ "[name='#{href}']"
    @$body.stop().animate scrollTop: $target.offset().top, 1000
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