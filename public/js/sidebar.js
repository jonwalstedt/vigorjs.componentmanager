(function ($)  {
  Sidebar = function () {
    this.$contentWrapper = $('.content-wrapper');
    this.$sidebar = $('.sidebar');
    this.origTop = this.$sidebar.offset().top;

    $(window).on('scroll', _.bind(this._onScroll, this));
    $(window).trigger('scroll');
  }

  Sidebar.prototype._onScroll = function (event) {
    scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    if (scrollTop > this.origTop) {
      this.$contentWrapper.addClass('sidebar--fixed');
    } else {
      this.$contentWrapper.removeClass('sidebar--fixed');
    }
  }

  new Sidebar();
})(jQuery)