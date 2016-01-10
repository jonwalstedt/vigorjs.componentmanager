var App,bind=function(t,i){return function(){return t.apply(i,arguments)}};App=function(){t.prototype.VIEWPORT_CUTOF=200;t.prototype.ACTIVE_LINK_CLASS="link--active";function t(){this._onMenuToggleClick=bind(this._onMenuToggleClick,this);this._onScroll=bind(this._onScroll,this);this._onLinkClick=bind(this._onLinkClick,this);this._scrollToTarget=bind(this._scrollToTarget,this);this._setActiveSectionFromScrollPosition=bind(this._setActiveSectionFromScrollPosition,this);this._updateActiveLinks=bind(this._updateActiveLinks,this);this.$window=$(window);this.$body=$("html, body");this.$links=$("a");this.$contentWrapper=$(".content-wrapper");this.$sidebarWrapper=$(".sidebar-wrapper");this.$menuToggle=$(".menu-toggle");this.$sidebar=$(".sidebar");this.$sectionHeaders=$(".sub-section > h3 > a");this.origTop=0;this._debouncedOnScroll=_.debounce(this._onScroll,10);this._debouncedSetActiveSectionFromScrollPosition=_.debounce(this._setActiveSectionFromScrollPosition,100);if(this.$sidebar.length){this.origTop=this.$sidebar.offset().top}setTimeout(function(t){return function(){var i,e,o;e=(o=window.location.hash)!=null?o.substring(1):void 0;i=$("[name='"+e+"']");if(i.length){return t._scrollToTarget(i)}}}(this),1e3);this._updateActiveLinks();this.$window.on("hashchange",this._updateActiveLinks);this.$window.on("scroll",this._debouncedOnScroll);this.$window.on("scroll",this._debouncedSetActiveSectionFromScrollPosition);this.$window.trigger("scroll");this.$menuToggle.on("click",this._onMenuToggleClick);$(".sidebar a, .docs .content a").on("click",this._onLinkClick);hljs.initHighlightingOnLoad()}t.prototype._updateActiveLinks=function(){var t,i,e;i=window.location.hash;e=window.location.pathname;t=$("[href='"+i+"'], [href='"+e+"']");this.$links.removeClass(this.ACTIVE_LINK_CLASS);return t.addClass(this.ACTIVE_LINK_CLASS)};t.prototype._setActiveSectionFromScrollPosition=function(){var t,i,e,o,n,s,r;s=this.$sectionHeaders;r=[];for(o=0,n=s.length;o<n;o++){i=s[o];t=$(i);if(this._isElementInTopOfViewport(i)){e=t.attr("name");t.removeAttr("name");window.location.hash=e;r.push(t.attr("name",e))}else{r.push(void 0)}}return r};t.prototype._isElementInTopOfViewport=function(t){var i;if(typeof jQuery==="function"&&t instanceof jQuery){t=t[0]}i=t.getBoundingClientRect();return i.top>=0&&i.left>=0&&i.bottom<=this.VIEWPORT_CUTOF&&i.right<=$(window).width()};t.prototype._scrollToTarget=function(t){return this.$body.stop().animate({scrollTop:t.offset().top},1e3)};t.prototype._onLinkClick=function(t){var i,e,o,n;i=$(t.currentTarget);o=i.attr("href").split("/").pop();if(o.indexOf("#")>-1){n=o.substring(1);e=$("[name='"+n+"']");if(e.length){this._scrollToTarget(e)}return t.preventDefault()}};t.prototype._onScroll=function(t){var i;i=document.documentElement.scrollTop||document.body.scrollTop;if(this.$sidebar.length){if(i>this.origTop){this.$sidebarWrapper.height(this.$sidebar.height());return this.$contentWrapper.addClass("sidebar--fixed")}else{this.$sidebarWrapper.removeAttr("style");return this.$contentWrapper.removeClass("sidebar--fixed")}}};t.prototype._onMenuToggleClick=function(){this.$menuToggle.toggleClass("menu-toggle--active");return this.$contentWrapper.toggleClass("sidebar--visible")};return t}();window.app=new App;