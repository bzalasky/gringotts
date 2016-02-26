(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var CollectionView, Handlebars, PaginatedView, utils;
    Handlebars = require('handlebars');
    utils = require('../../lib/utils');
    CollectionView = require('./collection-view');
    return PaginatedView = (function(superClass) {
      extend(PaginatedView, superClass);

      function PaginatedView() {
        return PaginatedView.__super__.constructor.apply(this, arguments);
      }

      PaginatedView.prototype.paginationPartial = 'pagination';


      /**
       * Overriding chaplin's toggleLoadingIndicator to
       * remove the collection length requirement.
       */

      PaginatedView.prototype.toggleLoadingIndicator = function() {
        var itemClassName, visible;
        itemClassName = utils.convenienceClass(this.itemView.prototype.className, this.itemView.prototype.template);
        if (!itemClassName) {
          throw new Error('Please define a className for your itemViews.');
        }
        visible = this.collection.isSyncing();
        this.$("." + (itemClassName.split(/\s+|\s+/).join('.'))).toggle(!visible);
        return this.$loading.toggle(visible);
      };

      PaginatedView.prototype._getPageInfo = function() {
        var info, max, maxItems, min, state;
        state = this.collection.getState({}, true);
        _.each(['page', 'per_page'], function(i) {
          return state[i] = parseInt(state[i]);
        });
        info = {
          viewId: this.cid,
          count: this.collection.count,
          page: state.page,
          perPage: state.per_page,
          pages: Math.ceil(this.collection.count / state.per_page),
          prev: false,
          next: false
        };
        maxItems = info.pages * info.perPage;
        max = Math.min(this.collection.count, info.page * info.perPage);
        if (this.collection.count === maxItems) {
          max = this.collection.count;
        }
        min = (info.page - 1) * info.perPage + 1;
        min = Math.min(min, max);
        info.range = [min, max].join('-');
        if (state.page > 1) {
          info.prev = state.page - 1;
        }
        if (state.page < info.pages) {
          info.next = state.page + 1;
        }
        info.routeName = this.routeName;
        info.routeParams = this.routeParams;
        info.multiPaged = info.count > info.perPage;
        info.nextState = info.next ? this.collection.getState({
          page: info.next
        }) : this.collection.getState();
        info.prevState = info.prev ? this.collection.getState({
          page: info.prev
        }) : this.collection.getState();
        return info;
      };


      /**
       * Add the pageInfo context into the view template.
       * Render using {{> pagination pageInfo}}.
       * @return {object} Context for use within the template.
       */

      PaginatedView.prototype.getTemplateData = function() {
        return _.extend(PaginatedView.__super__.getTemplateData.apply(this, arguments), {
          pageInfo: this._getPageInfo()
        });
      };

      PaginatedView.prototype.renderControls = function() {
        var pageInfo, template;
        PaginatedView.__super__.renderControls.apply(this, arguments);
        pageInfo = this._getPageInfo();
        template = Handlebars.partials[this.paginationPartial];
        if (!(pageInfo && template)) {
          return;
        }
        return this.$(".pagination-controls." + this.cid).each(function(i, el) {
          return $(el).replaceWith(template(pageInfo));
        });
      };

      return PaginatedView;

    })(CollectionView);
  });

}).call(this);
