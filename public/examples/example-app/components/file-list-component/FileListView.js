define(function (require) {

  'use strict';

  var FileListView,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      TweenMax = require('TweenMax'),
      Vigor = require('vigor'),
      ComponentViewBase = require('components/ComponentViewBase'),
      listTemplate = require('hbars!./templates/file-list-template'),
      listItemTemplate = require('hbars!./templates/file-list-item-template'),
      paginationTemplate = require('hbars!./templates/file-list-pagination-template');

  FileListView = ComponentViewBase.extend({

    className: 'file-list-component',
    fileType: undefined,
    currentPage: undefined,
    baseUrl: undefined,
    currentPage: 1,
    duration: 0.3,
    delay: 0.1,
    offset: 80,
    events: {
      'click .file-list__pagination-link': '_onPaginationLinkClick'
    },

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.urlParamsCollection = options.urlParamsCollection;
      this.urlParamsModel = this.urlParamsCollection.at(0);

      this.baseUrl = options.baseUrl || '#' + Backbone.history.fragment.split('/').shift();
      this.fileType = this.urlParamsModel.get('filetype');
      this.currentPage = this.urlParamsModel.get('page') || 1;

      this.listenTo(this.viewModel.listItems, 'reset', this._onListItemsReset);
      this.listenTo(this.urlParamsCollection, 'change:page', _.bind(this.renderDynamicContent, this));
      this.listenTo(this.urlParamsCollection, 'change:filetype', _.bind(this.renderDynamicContent, this));
    },

    renderStaticContent: function () {
      this.$el.html(listTemplate());
      this.$fileList = $('.file-list', this.$el);
      this.$fileListPagination = $('.file-list__pagination', this.$el);
      this._renderDeferred.resolve();
      return this;
    },

    renderDynamicContent: function () {
      var paginatedData, previousAttributes, previusPage, previusFileType, $previousItems;

      this.currentPage = this.urlParamsModel.get('page') || 1;
      this.fileType = this.urlParamsModel.get('filetype') || 'all';

      paginatedData = this.viewModel.getPaginatedFiles(this.currentPage, this.fileType);
      previousAttributes = this.urlParamsModel.previousAttributes();
      previusPage = +previousAttributes.page;
      previusFileType = previousAttributes.fileType;
      $previousItems = $('.file-list__list-item', this.$el);

      if (previusFileType != this.fileType) {
        this._renderPagination(paginatedData.pages);
      }

      if (!$previousItems.length) {
        this._renderListItems(paginatedData.listItems);
        TweenMax.staggerFromTo(
          $('.file-list__list-item', this.$el),
          this.duration * 4,
          {y: this.offset, autoAlpha: 0, ease: Quint.easeIn},
          {y: 0, autoAlpha: 1, ease: Quint.easeIn},
          this.delay
        );
      } else {
        if (this.currentPage > previusPage) {
          this._transitionListItemsToNext($previousItems, paginatedData.listItems);
        } else {
          this._transitionListItemsToPrev($previousItems, paginatedData.listItems);
        }
      }

      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.apply(this, arguments);
    },

    _transitionListItemsToNext: function ($previousItems, listItems) {
      TweenMax.staggerFromTo(
        $previousItems,
        this.duration,
        { y: 0, autoAlpha: 1 },
        { y: this.offset * -1, autoAlpha: 0, ease: Quint.easeIn },
        this.delay,
        function () {
          this._renderListItems(listItems);
          TweenMax.staggerFromTo(
            $('.file-list__list-item', this.$el).toArray().reverse(),
            this.duration,
            { y: this.offset, autoAlpha: 0},
            { y: 0, autoAlpha: 1, ease: Quint.easeIn },
            this.delay
          );
      }, [listItems], this);
    },

    _transitionListItemsToPrev: function ($previousItems, listItems) {
      TweenMax.staggerFromTo(
        $previousItems.toArray().reverse(),
        this.duration,
        { y: 0, autoAlpha: 1 },
        { y: this.offset, autoAlpha: 0, ease: Quint.easeIn },
        this.delay,
        function () {
          this._renderListItems(listItems);
          TweenMax.staggerFromTo(
            $('.file-list__list-item', this.$el).toArray().reverse(),
            this.duration,
            { y: this.offset * -1, autoAlpha: 0},
            { y: 0, autoAlpha: 1, ease: Quint.easeIn },
            this.delay
          );
      }, [listItems], this);
    },

    _renderListItems: function (listItems) {
      var $list = $(document.createDocumentFragment());
      this.$fileList.empty();
      listItems.forEach(function (item, index) {
        $list.append(listItemTemplate(item));
      }, this);
      this.$fileList.append($list);
    },

    _renderPagination: function (pages) {
      var $pagination = $(document.createDocumentFragment());
      this.$fileListPagination.empty();
      pages.forEach(function (pageItem, index) {
        pageItem.baseUrl = this.baseUrl;
        pageItem.fileType = this.fileType;
        $pagination.append(paginationTemplate(pageItem));
      }, this);
      this.$fileListPagination.append($pagination);
    },

    _onListItemsReset: function () {
      this.renderDynamicContent();
    },

    _onPaginationLinkClick: function (event) {
      var $links = $('.file-list__pagination-link', this.$el),
          $link = $(event.currentTarget);

      $links.removeClass('file-list__pagination-link--is-active');
      $link.addClass('file-list__pagination-link--is-active');
    }
  });

  return FileListView;

});