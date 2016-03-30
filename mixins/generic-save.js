(function() {
  define(function(require) {
    var _revertChanges, utils;
    utils = require('lib/utils');
    _revertChanges = function(opts, $xhr) {
      var message, ref, ref1, ref2, ref3, response;
      if ((ref = opts.$field) != null) {
        ref.text(opts.original);
      }
      if (opts.href) {
        if ((ref1 = opts.$field) != null) {
          ref1.attr('href', opts.href);
        }
      }
      if (!$xhr) {
        if (typeof this.makeEditable === "function") {
          this.makeEditable(opts);
        }
      }
      if ((ref2 = $xhr != null ? $xhr.status : void 0) === 400 || ref2 === 406) {
        if (response = utils.parseJSON($xhr.responseText)) {
          if (message = response.error || ((ref3 = response.errors) != null ? ref3[opts.attribute] : void 0)) {
            this.publishEvent('notify', message, {
              classes: 'alert-danger'
            });
            return $xhr.errorHandled = true;
          }
        }
      }
    };
    return {
      genericSave: function(opts) {
        opts = _.extend({}, _.omit(opts, ['success']), {
          wait: true,
          validate: false
        });
        if (opts.delayedSave) {
          return this.publishEvent('notify', opts.saveMessage, _.extend({}, opts, {
            success: function() {
              return opts.model.save(opts.attribute, opts.value, opts).fail((function(_this) {
                return function($xhr) {
                  return _revertChanges.call(_this, opts, $xhr);
                };
              })(this));
            },
            undo: (function(_this) {
              return function() {
                return _revertChanges.call(_this, opts);
              };
            })(this)
          }));
        } else {
          return opts.model.save(opts.attribute, opts.value, opts).done((function(_this) {
            return function() {
              return _this.publishEvent('notify', opts.saveMessage);
            };
          })(this)).fail((function(_this) {
            return function($xhr) {
              return _revertChanges.call(_this, opts, $xhr);
            };
          })(this));
        }
      }
    };
  });

}).call(this);
