(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Routing, handlebars, helper, utils;
    handlebars = require('handlebars');
    utils = require('lib/utils');
    helper = require('../helper');
    Routing = require('./routing');

    /**
     * Adds pagination support to a CollectionView. It relies on Routing
     * mixin to get current route name and params to generate pagination links.
     * @param  {CollectionView} base superclass
     */
    return function(base) {
      var Paginating;
      return Paginating = (function(superClass) {
        extend(Paginating, superClass);

        function Paginating() {
          return Paginating.__super__.constructor.apply(this, arguments);
        }


        /**
         * Name of handlebars partial with pagination controls.
         * @type {String}
         */

        Paginating.prototype.paginationPartial = 'pagination';

        Paginating.prototype.listen = {
          'request collection': function() {
            return this.renderPaginatingControls();
          },
          'sync collection': function() {
            return this.renderPaginatingControls();
          },
          'sort collection': function() {
            return this.renderPaginatingControls();
          }
        };

        Paginating.prototype.initialize = function() {
          var ref, ref1;
          helper.assertCollectionView(this);
          if (!_.isFunction((ref = this.collection) != null ? ref.getState : void 0)) {
            throw new Error('This view should have a collection with getState() method. Most probably with Paginated mixin applied.');
          }
          if (!_.isFunction((ref1 = this.collection) != null ? ref1.isSyncing : void 0)) {
            throw new Error('This view should have a collection with isSyncing() method. Most probably with ActiveSyncMachine mixin applied.');
          }
          return Paginating.__super__.initialize.apply(this, arguments);
        };


        /**
         * Add the pageInfo context into the view template.
         * Render using {{> pagination pageInfo}}.
         * @return {object} Context for use within the template.
         */

        Paginating.prototype.getTemplateData = function() {
          return _.extend(Paginating.__super__.getTemplateData.apply(this, arguments), {
            pageInfo: this.getPageInfo()
          });
        };

        Paginating.prototype.render = function() {
          if (!this.routeName) {
            throw new Error("Can't render view when routeName isn't set");
          }
          return Paginating.__super__.render.apply(this, arguments);
        };


        /**
         * Overriding chaplin's toggleLoadingIndicator to
         * remove the collection length requirement.
         */

        Paginating.prototype.toggleLoadingIndicator = function() {
          var visible;
          visible = this.collection.isSyncing();
          this.$('tbody > tr').not(this.loadingSelector).not(this.fallbackSelector).not(this.errorSelector).toggle(!visible);
          return this.$loading.toggle(visible);
        };

        Paginating.prototype.getStats = function(min, max, info) {
          if (typeof I18n !== "undefined" && I18n !== null) {
            return I18n.t('items.total', {
              start: min,
              end: max,
              total: info.count
            });
          } else {
            return ([min, max].join('-')) + " of " + info.count;
          }
        };

        Paginating.prototype.getRangeString = function(page, perPage, info) {
          var max, maxItems, min;
          maxItems = info.pages * perPage;
          max = info.count === maxItems ? info.count : Math.min(info.count, page * perPage);
          min = (page - 1) * perPage + 1;
          min = Math.min(min, max);
          return this.getStats(min, max, info);
        };

        Paginating.prototype.getPageInfo = function() {
          var infinite, info, page, perPage, state;
          infinite = this.collection.infinite;
          state = this.collection.getState({}, {
            inclDefaults: true,
            usePrefix: false
          });
          perPage = parseInt(state.per_page);
          page = infinite ? state.page : parseInt(state.page);
          info = {
            viewId: this.cid,
            count: this.collection.count,
            page: page,
            perPage: perPage
          };
          if (infinite) {
            info.pages = 1;
            info.multiPaged = true;
            info.prev = page !== 1 ? 1 : 0;
            info.next = this.collection.nextPageId;
          } else {
            info.pages = Math.ceil(this.collection.count / perPage);
            info.multiPaged = this.collection.count > perPage;
            info.prev = page > 1 ? page - 1 : 0;
            info.next = page < info.pages ? page + 1 : 0;
            info.range = this.getRangeString(page, perPage, info);
          }
          info.nextState = info.next ? this.collection.getState({
            page: info.next
          }) : this.collection.getState();
          info.prevState = info.prev ? this.collection.getState({
            page: info.prev
          }) : this.collection.getState();
          info.routeName = this.routeName;
          info.routeParams = this.routeParams;
          return info;
        };

        Paginating.prototype.renderPaginatingControls = function() {
          var pageInfo, template;
          pageInfo = this.getPageInfo();
          template = handlebars.partials[this.paginationPartial];
          if (!(pageInfo && template)) {
            return;
          }
          return this.$(".pagination-controls." + this.cid).each(function(i, el) {
            return $(el).replaceWith(template(pageInfo));
          });
        };

        return Paginating;

      })(utils.mix(base)["with"](Routing));
    };
  });

}).call(this);
