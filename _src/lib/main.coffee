# # ObjSchema

# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)

#
# ### Exports: *Class*
#
# Main Module
# 
_isFunction = require( "lodash/isFunction" )
_isNumber = require( "lodash/isNumber" )
_isArray = require( "lodash/isArray" )
_isBoolean = require( "lodash/isBoolean" )
_isObject = require( "lodash/isObject" )
_isString = require( "lodash/isString" )
_isObject = require( "lodash/isObject" )
_isRegExp = require( "lodash/isRegExp" )
_template = require( "lodash/template" )

moment = require( "moment-timezone" )
sanitizer = require( "sanitizer" )
htmlStrip = require('js-striphtml')

class ObjSchemaError extends Error
	statusCode: 406
	customError: true
	
	constructor: ( @nane = @constructor.name, @message = "-" )->
		@stack = (new Error).stack
		return


module.exports = class ObjSchema

	defaults: ->
		name: "data"

	constructor: ( @schema, options )->
		
		@isArray = _isArray( @schema )
		@config = @defaults()
		@config.name = options.name if options.name?
		@config.customerror = options.customerror if options.customerror? and _isFunction( options.customerror )
		
		@_initMsgs()
		return

	keys: =>
		return Object.keys( @schema )

	_validateEmailRegex: /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/

	validateCb: ( [data, options]..., cb )=>
		_err = @validate( data )
		if not _err?
			return

		if not cb?
			throw _err

		if _isFunction( cb )
			cb( _err )
			return _err

		return _err
	
	validateMulti: ( data, options )=>
		errors = []
		if @isArray
			for def, idx in @schema
				def.idx = idx
				[ err, _val ] = @_validateKey( idx, data[ idx ], def, data, options )
				errors.push( err ) if err
		else
			for _k, def of @schema
				[ err, _val ] = @_validateKey( _k, data[ _k ], def, data, options )
				errors.push( err ) if err
			
		if errors.length
			return errors
		else
			return null
	
	validate: ( data, options )=>
		if @isArray
			for def, idx in @schema
				def.idx = idx
				[ err, _val ] = @_validateKey( idx, data[ idx ], def, data, options )
				return err if err?
		else
			for _k, def of @schema
				[ err, _val ] = @_validateKey( _k, data[ _k ], def, data, options )
				return err if err?
		return null
	
	validateKey: ( key, val, options )=>
		if not @schema[ key ]
			return null
		if @isArray
			def.idx = key
		[ err, _val ] = @_validateKey( key, val, @schema[ key ], null, options )
		if err?
			return err
		return _val
	
	trim: ( str )->
		return str.replace(/^\s+|\s+$/g, '')

	_validateKey: ( key, val, def, data, options )=>
		if _isFunction( def.fnSkip ) and def.fnSkip( key, val, data, options )
			return [ null, val ]
		
		if _isNumber( key )
			_key = def.key
		else
			_key = key
		
		if def.required and not val?
			return [ @_error( "required", _key, def ), val ]
		else if not val?
			if def.default?
				if _isFunction( def.default )
					val = def.default( key, val, data, options )
				else
					val = def.default
				data[ key ] = val if data?

		
		switch def.type
			when "number"
				if val? and ( not _isNumber( val ) )
					return [ @_error( "number", _key, def ), val ]

			when "array"
				if val? and ( not _isArray( val ) )
					return [ @_error( "array", _key, def ), val ]

			when "boolean"
				if val? and ( not _isBoolean( val ) )
					return [ @_error( "boolean", _key, def ), val ]

			when "object"
				if val? and ( not _isObject( val ) )
					return [ @_error( "object", _key, def ), val ]

			when "string", "enum"
				if val? and ( not _isString( val ) )
					return [ @_error( "string", _key, def ), val ]

			when "email"
				if val? and ( not _isString( val ) or not val.match( @_validateEmailRegex ) )
					return [ @_error( "email", _key, def ), val ]

			when "timezone"
				if val? and ( not _isString( val ) or not moment.tz.zone( val ) )
					return [ @_error( "timezone", _key, def ), val ]

			when "schema"
				if val? and def.schema.isArray and not _isArray( val )
					return [ @_error( "schema", _key, def, { st: "array" } ), val ]
				if val? and not def.schema.isArray and not ( _isObject( val ) and not _isArray( val ) )
					return [ @_error( "schema", _key, def, { st: "object" } ), val ]
				if val? and _isObject( val ) and def.schema instanceof ObjSchema
					_err = def.schema.validate( val )
					return [ _err if _err?, val ]

		if val? and def.type is "string" and _isRegExp( def.regexp ) and not val.match( def.regexp )
			return [ @_error( "regexp", _key, def, { regexp: def.regexp.toString() } ), val ]

		if val? and def.type is "string" and def.sanitize
			val = sanitizer.sanitize( val )
			data[ key ] = val if data?
			
		if val? and def.type is "string" and def.striphtml?
			if _isArray( def.striphtml )
				val = htmlStrip.stripTags( val, def.striphtml )
			else
				val = htmlStrip.stripTags( val )
			data[ key ] = val if data?

		if val? and def.type is "string" and def.trim
			val = @trim( val )
			data[ key ] = val if data?

		if val? and def.type in [ "number", "string", "array"]  and def.check?.operand? and def.check?.value?
			if def.type in ["string", "array"]
				_ename = "length"
				_val = val.length
			else
				_ename = "check"
				_val = val
			
			switch def.check.operand.toLowerCase()
				when "eq", "=", "=="
					if _val isnt def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "eq", value: def.check.value }, "info": "not equal `#{def.check.value}`" } ), val ]
				when "neq", "!="
					if _val is def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "neq", value: def.check.value }, "info": "equal `#{def.check.value}`" } ), val ]
				when "gt", ">"
					if _val <= def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "gt", value: def.check.value }, "info": "to low" } ), val ]
				when "gte", ">="
					if _val < def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "gte", value: def.check.value }, "info": "to low" } ), val ]
				when "lt", "<"
					if _val >= def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "lt", value: def.check.value }, "info": "to high" } ), val ]
				when "lte", "<="
					if _val > def.check.value
						return [ @_error( _ename, _key, def, { check: { operand: "lte", value: def.check.value }, "info": "to high" } ), val ]
				when "between", "btw", "><"
					if _isArray( def.check?.value ) and def.check.value.length is 2 and ( _val < def.check.value[0] or _val > def.check.value[1] )
						return [ @_error( _ename, _key, def, { check: { operand: "between", value: def.check.value }, "info": "not between `#{def.check.value[0]}` and `#{def.check.value[0]}`" } ), val ]
		
		if val? and def.type is "enum" and def.values? and val not in def.values
			return [ @_error( "enum", _key, def, { values: def.values.join(", ") } ), val ]

		if def.foreignReq? and _isArray( def.foreignReq )
			for _fkey in def.foreignReq when not data[ _fkey ]?
				return [ @_error( "required", _fkey, @schema[ _fkey ] ), val ]
				
		return [ null, val ]
		
	_error: ( errtype, key, def, opt )=>
		if @config.customerror?
			return @config.customerror.call( @, errtype, key, def, opt, @config )
		return @error( errtype, key, def, opt )
		
	error: (  errtype, key, def, opt )=>
		_err = new ObjSchemaError()
		_err.name = "EVALIDATION_" + @config.name.toUpperCase() + "_" + errtype.toUpperCase() + "_" + key.toUpperCase()
		_err.message = @msgs[ errtype ]?( { key: key, def: def, opt: opt } ) or "-"
		_err.type = errtype
		_err.field = key
		_err.check = opt.check if opt?.check?
		_err.def = def
		#_err.opt = opt if opt?
		return _err
	
	_initMsgs: =>
		@msgs = {}
		for key, msg of @_ERRORMSGS
			@msgs[ key ] = _template( msg )
		return

	_ERRORMSGS:
		required: "Please define the value `<%= key %>`"
		number: "The value in `<%= key %>` has to be a number"
		schema: "The value in `<%= key %>` has to be a <%= opt.st %> to match against the sub schema"
		string: "The value in `<%= key %>` has to be a string"
		array: "The value in `<%= key %>` has to be an array"
		boolean: "The value in `<%= key %>` has to be a boolean"
		object: "The value in `<%= key %>` has to be a object"
		check: "The value in `<%= key %>` is <%= opt.info %>"
		length: "The <%= def.type %> length in `<%= key %>` is <%= opt.info %>"
		email: "The value in `<%= key %>` has to be a valid email"
		timezone: "The value in `<%= key %>` has to be a valid timezone. Please check the moment-timezone (http://momentjs.com/timezone)"
		enum: "The value in `<%= key %>` has to be one of `<%= opt.values %>`"
		regexp: "The value in `<%= key %>` does not match the regural expression <%= opt.regexp %>"
