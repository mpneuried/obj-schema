var ObjSchema, ObjSchemaError, _, htmlStrip, moment, sanitizer,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require("lodash");

moment = require("moment-timezone");

sanitizer = require("sanitizer");

htmlStrip = require('htmlstrip-native').html_strip;

ObjSchemaError = (function(superClass) {
  extend(ObjSchemaError, superClass);

  ObjSchemaError.prototype.statusCode = 406;

  ObjSchemaError.prototype.customError = true;

  function ObjSchemaError(nane, message) {
    this.nane = nane != null ? nane : this.constructor.name;
    this.message = message != null ? message : "-";
    this.stack = (new Error).stack;
    return;
  }

  return ObjSchemaError;

})(Error);

module.exports = ObjSchema = (function(superClass) {
  extend(ObjSchema, superClass);

  ObjSchema.prototype.defaults = function() {
    return _.extend(ObjSchema.__super__.defaults.apply(this, arguments), {
      name: "data"
    });
  };

  function ObjSchema(schema, options) {
    this.schema = schema;
    this._initMsgs = bind(this._initMsgs, this);
    this._error = bind(this._error, this);
    this.validate = bind(this.validate, this);
    this.validateCb = bind(this.validateCb, this);
    this.keys = bind(this.keys, this);
    this.defaults = bind(this.defaults, this);
    ObjSchema.__super__.constructor.call(this, options);
    this._initMsgs();
    return;
  }

  ObjSchema.prototype.keys = function() {
    return Object.keys(this.schema);
  };

  ObjSchema.prototype._validateEmailRegex = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;

  ObjSchema.prototype.validateCb = function(data, cb) {
    var _err;
    _err = this.validate(data);
    if (_err == null) {
      return;
    }
    if (cb == null) {
      throw _err;
    }
    if (_.isFunction(cb)) {
      cb(_err);
      return _err;
    }
    return _err;
  };

  ObjSchema.prototype.validate = function(data) {
    var __val, _ename, _err, _fkey, _k, _val, def, i, len, ref, ref1, ref2, ref3, ref4;
    ref = this.schema;
    for (_k in ref) {
      def = ref[_k];
      _val = data[_k];
      if (def.required && (_val == null)) {
        return this._error("required", _k, def);
      } else if (_val == null) {
        if (def["default"] != null) {
          if (_.isFunction(def["default"])) {
            _val = data[_k] = def["default"](data, def);
          } else {
            _val = data[_k] = def["default"];
          }
        }
      }
      switch (def.type) {
        case "number":
          if ((_val != null) && (!_.isNumber(_val))) {
            return this._error("number", _k, def);
          }
          break;
        case "array":
          if ((_val != null) && (!_.isArray(_val))) {
            return this._error("array", _k, def);
          }
          break;
        case "boolean":
          if ((_val != null) && (!_.isBoolean(_val))) {
            return this._error("boolean", _k, def);
          }
          break;
        case "object":
          if ((_val != null) && (!_.isObject(_val))) {
            return this._error("object", _k, def);
          }
          break;
        case "string":
        case "enum":
          if ((_val != null) && (!_.isString(_val))) {
            return this._error("string", _k, def);
          }
          break;
        case "email":
          if ((_val != null) && (!_.isString(_val) || !_val.match(this._validateEmailRegex))) {
            return this._error("email", _k, def);
          }
          break;
        case "timezone":
          if ((_val != null) && (!_.isString(_val) || !moment.tz.zone(_val))) {
            return this._error("timezone", _k, def);
          }
          break;
        case "schema":
          if ((_val != null) && _.isObject(_val) && def.schema instanceof ObjSchema) {
            _err = def.schema.validate(_val);
            if (_err != null) {
              return _err;
            }
          }
      }
      if ((_val != null) && def.type === "string" && _.isRegExp(def.regexp) && !_val.match(def.regexp)) {
        return this._error("regexp", _k, def, {
          regexp: def.regexp.toString()
        });
      }
      if ((_val != null) && def.type === "string" && def.sanitize) {
        data[_k] = sanitizer.sanitize(data[_k]);
      }
      if ((_val != null) && def.type === "string" && def.striphtml) {
        data[_k] = htmlStrip(data[_k]);
      }
      if ((_val != null) && def.type === "string" && def.trim) {
        data[_k] = this.trim(data[_k]);
      }
      if ((_val != null) && ((ref1 = def.type) === "number" || ref1 === "string") && (((ref2 = def.check) != null ? ref2.operand : void 0) != null) && (((ref3 = def.check) != null ? ref3.value : void 0) != null)) {
        if (def.type === "string") {
          _ename = "length";
          __val = _val.length;
        } else {
          _ename = "check";
          __val = _val;
        }
        switch (def.check.operand.toLowerCase()) {
          case "eq":
          case "=":
          case "==":
            if (__val !== def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "not equal `" + def.check.value + "`"
              });
            }
            break;
          case "neq":
          case "!=":
            if (__val === def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "equal `" + def.check.value + "`"
              });
            }
            break;
          case "gt":
          case ">":
            if (__val <= def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "to low"
              });
            }
            break;
          case "gte":
          case ">=":
            if (__val < def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "to low"
              });
            }
            break;
          case "lt":
          case "<":
            if (__val >= def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "to high"
              });
            }
            break;
          case "lte":
          case "<=":
            if (__val > def.check.value) {
              return this._error(_ename, _k, def, {
                "info": "to high"
              });
            }
        }
      }
      if ((_val != null) && def.type === "enum" && (def.values != null) && indexOf.call(def.values, _val) < 0) {
        return this._error("enum", _k, def, {
          values: def.values.join(", ")
        });
      }
      if ((def.foreignReq != null) && _.isArray(def.foreignReq)) {
        ref4 = def.foreignReq;
        for (i = 0, len = ref4.length; i < len; i++) {
          _fkey = ref4[i];
          if (data[_fkey] == null) {
            return this._error("required", _fkey, this.schema[_fkey]);
          }
        }
      }
    }
    return null;
  };

  ObjSchema.prototype.trim = function(str) {
    return str.replace(/^\s+|\s+$/g, '');
  };

  ObjSchema.prototype._error = function(errtype, key, def, opt) {
    var _err, base;
    _err = new ObjSchemaError();
    _err.name = "EVALIDATION_" + this.config.name.toUpperCase() + "_" + errtype.toUpperCase() + "_" + key.toUpperCase();
    _err.message = (typeof (base = this.msgs)[errtype] === "function" ? base[errtype]({
      key: key,
      def: def,
      opt: opt
    }) : void 0) || "-";
    _err.type = errtype;
    _err.field = key;
    if (opt != null) {
      _err.opt = opt;
    }
    return _err;
  };

  ObjSchema.prototype._initMsgs = function() {
    var key, msg, ref;
    this.msgs = {};
    ref = this._ERRORMSGS;
    for (key in ref) {
      msg = ref[key];
      this.msgs[key] = _.template(msg);
    }
  };

  ObjSchema.prototype._ERRORMSGS = {
    required: "Please define the value `<%= key %>`",
    number: "The value in `<%= key %>` has to be a number",
    string: "The value in `<%= key %>` has to be a string",
    array: "The value in `<%= key %>` has to be an array",
    boolean: "The value in `<%= key %>` has to be a boolean",
    object: "The value in `<%= key %>` has to be a object",
    check: "The value in `<%= key %>` is <%= opt.info %>",
    length: "The string length in `<%= key %>` is <%= opt.info %>",
    email: "The value in `<%= key %>` has to be a valid email",
    timezone: "The value in `<%= key %>` has to be a valid timezone. Please check the moment-timezone (http://momentjs.com/timezone)",
    "enum": "The value in `<%= key %>` has to be one of `<%= opt.values %>`",
    regexp: "The value in `<%= key %>` does not match the regural expression <%= opt.regexp %>"
  };

  return ObjSchema;

})(require("mpbasic")());
