# # ObjSchema

# ### extends [NPM:MPBasic](https://cdn.rawgit.com/mpneuried/mpbaisc/master/_docs/index.coffee.html)

#
# ### Exports: *Class*
#
# Main Module
# 
_ = require( "lodash" )
moment = require( "moment-timezone" )
sanitizer = require( "sanitizer" )
htmlStrip = require('htmlstrip-native').html_strip

module.exports = class ObjSchema extends require( "mpbasic" )()

	defaults: =>
		_.extend super, 
			name: "data"

	constructor: ( @schema, options )->
		super( options )
		@_initMsgs()
		return

	keys: =>
		return Object.keys( @schema )

	_validateEmailRegex: /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/

	validateCb: ( data, cb )=>
		_err = @validate( data )
		if not _err?
			return

		if not cb?
			throw _err

		if _.isFunction( cb )
			cb( _err )
			return _err

		return _err

	validate: ( data )=>
		for _k, def of @schema
			_val = data[ _k ]
			if def.required and not _val?
				return @_error( "required", _k, def )
			else if not _val?
				if def.default?
					if _.isFunction( def.default )
						_val = data[ _k ] = def.default( data, def )
					else
						_val = data[ _k ] = def.default

			switch def.type 

				when "number"
					if _val? and ( not _.isNumber( _val ) )
						return @_error( "number", _k, def )

				when "array"
					if _val? and ( not _.isArray( _val ) )
						return @_error( "array", _k, def )

				when "boolean"
					if _val? and ( not _.isBoolean( _val ) )
						return @_error( "boolean", _k, def )

				when "object"
					if _val? and ( not _.isObject( _val ) )
						return @_error( "object", _k, def )

				when "string", "enum"
					if _val? and ( not _.isString( _val ) )
						return @_error( "string", _k, def )

				when "email"
					if _val? and ( not _.isString( _val ) or not _val.match( @_validateEmailRegex ) )
						return @_error( "email", _k, def )

				when "timezone"
					if _val? and ( not _.isString( _val ) or not moment.tz.zone( _val ) )
						return @_error( "timezone", _k, def )

				when "schema"
					if _val? and _.isObject( _val ) and def.schema instanceof ObjSchema
						_err = def.schema.validate( _val )
						return _err if _err?

			if _val? and def.type is "string" and _.isRegExp( def.regexp ) and not _val.match( def.regexp )
				return @_error( "regexp", _k, def, { regexp: def.regexp.toString() } )

			if _val? and def.type is "string" and def.sanitize
				data[ _k ] = sanitizer.sanitize( data[ _k ] )

			if _val? and def.type is "string" and def.striphtml
				data[ _k ] = htmlStrip( data[ _k ] )

			if _val? and def.type is "number"  and def.check?.operand? and def.check?.value?
				switch def.check.operand.toLowerCase()
					when "eq", "=", "=="
						if _val isnt def.check.value
							return @_error( "check", _k, def, { "info": "not equal" } )
					when "neq", "!="
						if _val is def.check.value
							return @_error( "check", _k, def, { "info": "equal" } )
					when "gt", ">"
						if _val <= def.check.value
							return @_error( "check", _k, def, { "info": "to low" } )
					when "gte", ">="
						if _val < def.check.value
							return @_error( "check", _k, def, { "info": "to low" } )
					when "lt", "<"
						if _val >= def.check.value
							return @_error( "check", _k, def, { "info": "to high" } )
					when "lte", "<="
						if _val > def.check.value
							return @_error( "check", _k, def, { "info": "to high" } )

			if _val? and def.type is "enum" and def.values? and _val not in def.values
				return @_error( "enum", _k, def, { values: def.values.join(", ") } )

			if def.foreignReq? and _.isArray( def.foreignReq )
				for _fkey in def.foreignReq when not data[ _fkey ]?
					return @_error( "required", _fkey, @schema[ _fkey ] )

		return null	


	_error: ( errtype, key, def, opt )=>
		_err = new Error()
		_err.name = "EVALIDATION_" + @config.name.toUpperCase() + "_" + errtype.toUpperCase() + "_" + key.toUpperCase()
		_err.message = @msgs[ errtype ]?( { key: key, def: def, opt: opt } ) or "-"
		_err.statusCode = 406
		_err.customError = true
		return _err
	
	_initMsgs: =>
		@msgs = {}
		for key, msg of @_ERRORMSGS
			@msgs[ key ] = _.template( msg )
		return

	_ERRORMSGS: 
		required: "Please define the value `<%= key %>`"
		number: "The value in `<%= key %>` has to be a number"
		string: "The value in `<%= key %>` has to be a string"
		array: "The value in `<%= key %>` has to be an array"
		boolean: "The value in `<%= key %>` has to be a boolean"
		object: "The value in `<%= key %>` has to be a object"
		check: "The value in `<%= key %>` is <%= opt.info %>"
		email: "The value in `<%= key %>` has to be a valid email"
		timezone: "The value in `<%= key %>` has to be a valid timezone. Please check the moment-timezone (http://momentjs.com/timezone)"
		enum: "The value in `<%= key %>` has to be one of `<%= opt.values %>`"
		regexp: "The value in `<%= key %>` does not match the regural expression <%= opt.regexp %>"

