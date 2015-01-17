(function() {
  var Conveyor, Promise, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('underscore');

  Promise = require('bluebird');

  Conveyor = (function() {
    function Conveyor(data) {
      this.data = _.extend({}, data);
      this.lastInput = null;
      this.lastOutput = null;
      this.currentPlugin = null;
      this.promise = Promise.resolve(_.omit(this, 'then', 'catch', 'done'));
    }

    Conveyor.prototype.extract = function(path) {
      if (_.isUndefined(path)) {
        path = this.lastOutput;
      }
      this.lastInput = path;
      if (_.isNull(path)) {
        return [this.data];
      }
      if (_.isString(path)) {
        return [Conveyor.util.prop(this.data, path)];
      }
      if (_.isArray(path)) {
        return _.map(path, (function(_this) {
          return function(i) {
            return Conveyor.util.prop(_this.data, i);
          };
        })(this));
      }
      throw new Error('Pipeline.extract: Unexpected path type: ' + typeof path);
    };

    Conveyor.prototype.insert = function(path, value) {
      if (_.isNull(path)) {
        this.lastOutput = null;
        _.extend(this.data, value);
        return this;
      }
      if (_.isString(path)) {
        this.lastOutput = path;
        Conveyor.util.prop(this.data, path, value);
        return this;
      }
      if (_.isUndefined(path)) {
        if (_.isString(this.lastInput)) {
          this.lastOutput = this.lastInput;
          Conveyor.util.prop(this.data, this.lastInput, value);
        } else {
          this.lastOutput = null;
        }
        return this;
      }
      throw new Error('Pipeline.insert: Unexpected path type: ' + typeof path);
    };

    Conveyor.prototype.panic = function(message, details) {
      throw new Conveyor.Error(message, details);
    };

    Conveyor.prototype.then = function() {
      var config, fn, self, wrapper;
      self = this;
      if (_.isFunction(arguments[0])) {
        config = {};
        fn = arguments[0];
      } else if (_.isObject(arguments[0]) && _.isFunction(arguments[1])) {
        config = arguments[0];
        fn = arguments[1];
      } else {
        throw new Error('Unexpected arguments! You need an optional config object and a function.');
      }
      wrapper = function(conveyor) {
        var args, context, result;
        if (!conveyor) {
          conveyor = self;
        }
        args = conveyor.extract(config.input);
        context = _.extend({}, {
          config: config,
          conveyor: conveyor
        });
        result = fn.apply(context, args);
        return Promise.resolve(result).then(function(result) {
          return conveyor.insert(config.output, result);
        });
      };
      this.promise = this.promise.then(wrapper);
      return this;
    };

    Conveyor.prototype["catch"] = function() {
      var config, conveyor, fn, wrapper;
      conveyor = this;
      if (_.isFunction(arguments[0])) {
        config = {};
        fn = arguments[0];
      } else if (_.isObject(arguments[0]) && _.isFunction(arguments[1])) {
        config = arguments[0];
        fn = arguments[1];
      } else {
        throw new Error('Unexpected arguments! You need an optional config object and a function.');
      }
      wrapper = function(error) {
        var context, errType, _ref;
        errType = (_ref = config.type) != null ? _ref : null;
        context = _.extend({}, {
          config: config,
          conveyor: conveyor
        });
        return fn.call(context, error);
      };
      if (_.isFunction(config.type)) {
        this.promise = this.promise["catch"].call(this.promise, config.type, wrapper);
      } else {
        this.promise = this.promise["catch"].call(this.promise, wrapper);
      }
      return this;
    };

    Conveyor.prototype.done = function() {
      this.promise.done();
      return this;
    };

    Conveyor.util = {
      prop: function(obj, prop, value) {
        var list, n;
        if ((!prop) || (!obj)) {
          return;
        }
        list = prop.replace(/\[(\w+)\]/g, '.$1').replace(/^\./, '').split('.');
        while (list.length > 1) {
          n = list.shift();
          if (_.isUndefined(obj[n])) {
            if (_.isUndefined(value)) {
              return;
            } else {
              obj[n] = {};
            }
          }
          obj = obj[n];
        }
        if (_.isUndefined(value)) {
          if (!obj) {
            return null;
          } else {
            return obj[list[0]];
          }
        } else {
          return obj[list[0]] = value;
        }
      }
    };

    return Conveyor;

  })();

  Conveyor.Error = (function(_super) {
    __extends(Error, _super);

    function Error(message, details) {
      this.message = message;
      this.details = details;
      if (this.details && this.details.toString !== Object.prototype.toString) {
        this.message += ' (' + this.details.toString() + ')';
      }
      Error.__super__.constructor.call(this, this.message);
    }

    Error.prototype.toString = function() {
      return this.message;
    };

    return Error;

  })(Error);

  module.exports = Conveyor;

}).call(this);
