(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  define(function(require) {
    var Chaplin, View, advice, convenienceClass, stringTemplate;
    Chaplin = require('chaplin');
    advice = require('../../mixins/advice');
    convenienceClass = require('../../mixins/convenience-class');
    stringTemplate = require('../../mixins/string-template');
    return View = (function(superClass) {
      extend(View, superClass);

      function View() {
        return View.__super__.constructor.apply(this, arguments);
      }

      _.extend(View.prototype, stringTemplate);

      advice.call(View.prototype);

      convenienceClass.call(View.prototype);

      View.prototype.autoRender = true;

      View.prototype.optionNames = Chaplin.View.prototype.optionNames.concat(['template']);

      return View;

    })(Chaplin.View);
  });

}).call(this);
