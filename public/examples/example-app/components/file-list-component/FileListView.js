define(function (require) {

  'use strict';

  var FileListView,
      $ = require('jquery'),
      _ = require('underscore'),
      Backbone = require('backbone'),
      TweenMax = require('TweenMax'),
      Vigor = require('vigor'),
      ComponentViewBase = require('components/ComponentViewBase'),
      listTemplate = require('hbars!./templates/file-list-template');

  FileListView = ComponentViewBase.extend({

    className: 'file-list-component',
    currentPage: 0,

    initialize: function (options) {
      ComponentViewBase.prototype.initialize.apply(this, arguments);
      this.urlParamsCollection = options.urlParamsCollection;
      this.urlParamsModel = this.urlParamsCollection.at(0);

      this.baseUrl = options.baseUrl || Backbone.history.fragment.split('/').shift();
      this.fileType = this.urlParamsModel.get('filetype');
      this.currentPage = this.urlParamsModel.get('page') || 0;

      this.listenTo(this.viewModel.listItems, 'reset', this.renderDynamicContent);
      this.listenTo(this.urlParamsCollection, 'change:page', _.bind(this._onIdChange, this));
    },

    renderStaticContent: function () {
      this.$el.html('Loading items...');
      return this;
    },

    renderDynamicContent: function () {
      var paginatedData = this.viewModel.paginateListItems(this.currentPage),
          duration = 0.3,
          delay = 0.1,
          dirOne = -1,
          dirTwo = 1,
          yTarget = 80,
          templateData = {
            listItems: paginatedData.listItems,
            pages: paginatedData.pages,
            baseUrl: '#' + this.baseUrl,
            fileType: this.fileType,
            currentPage: this.currentPage
          },
          $previousPageItems = $('.file-list__list-item', this.$el);

      if ($previousPageItems.length) {
        var previusPage = +this.urlParamsModel.previousAttributes().page;
        if (this.currentPage > previusPage) {
          dirOne = 1;
          dirTwo = -1;
        }

        TweenMax.staggerFromTo(
          $previousPageItems.toArray().reverse(),
          duration,
          { y: 0, autoAlpha: 1 },
          { y: yTarget * dirOne, autoAlpha: 0, ease: Quint.easeIn },
          delay,
          function () {
            this.$el.html(listTemplate(templateData));
            TweenMax.staggerFromTo(
              $('.file-list__list-item', this.$el).toArray().reverse(),
              duration,
              { y: yTarget * dirTwo, autoAlpha: 0, ease: Quint.easeIn },
              { y: 0, autoAlpha: 1 },
              delay
            );
        }, [], this);
      } else {
        this.$el.html(listTemplate(templateData));
        TweenMax.staggerFromTo(
          $('.file-list__list-item', this.$el),
          duration * 4,
          {y: yTarget, autoAlpha: 0, ease: Quint.easeIn},
          {y: 0, autoAlpha: 1, ease: Quint.easeIn, ease: Quint.easeIn},
          delay
        );
      }

      this._renderDeferred.resolve();
      return this;
    },

    addSubscriptions: function () {
      this.viewModel.addSubscriptions();
    },

    removeSubscriptions: function () {
      this.viewModel.removeSubscriptions();
    },

    dispose: function () {
      ComponentViewBase.prototype.dispose.call(this, arguments);
    },

    _onIdChange: function (model, value) {
      this.currentPage = value;
      this.renderDynamicContent();
    },

    _onListItemsAdd: function (addedItem, collection, options) {
      console.log(addedItem, collection, options);
      // var helloWorldItemModel = new app.HelloWorldItemViewModel(addedItem.id),
      //     helloWorldItemView = new app.HelloWorldItemView({ viewModel: helloWorldItemModel });

      // helloWorldItemView.render();
      // this._helloWorldItems.push(helloWorldItemView);
      // this.renderDynamicContent();
    },

    _onListItemsRemove: function (removedItem, collection, options) {
      // var removedComponent = this._helloWorldItems.splice(options.index, 1)[0];

      // if (removedComponent) {
      //   removedComponent.el.remove();
      //   removedComponent.dispose();
      // }
    }
  });

  return FileListView;

});