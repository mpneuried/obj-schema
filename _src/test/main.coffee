should = require('should')
_map = require('lodash/map')

Schema = require( "../." )

userValidator = null
settingsValidator = null

describe "OBJ-SCHEMA -", ->

	before ( done )->
		settingsValidator = new Schema(
			"a":
				type: "string"
				required: true

			"b":
				type: "number"
		
		, { name: "settings" } )

		userValidator = new Schema(
			"name":
				type: "string"
				required: true
				check:
					operand: ">="
					value: 4
			
			"nickname":
				type: "string"
				check:
					operand: "<"
					value: 10
					
			"type":
				type: "string"
				check:
					operand: "eq"
					value: 2

			"sex":
				type: "string"
				regexp: /^(m|w)$/gi

			"email":
				type: "email"
			
			"age":
				type: "number"
				default: 42
				check:
					operand: ">"
					value: 0

			"money":
				type: "number"
				check:
					operand: "btw"
					value: [1000,5000]

			"comment":
				type: "string"
				striphtml: true

			"tag":
				type: "enum"
				values: [ "A", "B", "C" ]
			
			"list":
				type: "array"
				check:
					operand: "btw"
					value: [2,4]
			
			"timezone":
				type: "timezone"

			"settings":
				type: "schema"
				schema: settingsValidator

			"props":
				type: "object"

			"active":
				type: "boolean"
				default: true
			
			"flagA":
				type: "boolean"
				
			"flagB":
				type: "boolean"
		
			"checkA":
				type: "number"
				check:
					operand: "neq"
					value: 23

			"checkB":
				type: "number"
				check:
					operand: "eq"
					value: 23

		, { name: "user" } )

		done()
		return

	after ( done )->
		#  TODO teardown
		done()
		return

	describe 'Main -', ->

		it "success", ( done )->
			_data =
				name: "John"
				nickname: "johndoe"
				type: "ab"
				email: "john@do.com"
				sex: "M"
				tag: "A"
				list: [1,2,3]
				age: 23
				timezone: "CET"
				settings: { a: "foo" }
				props: { foo: "bar" }
				active: false
				money: 1001
				checkA: 42
				checkB: 23
				flagA: false
				flagB: true
				comment: "a <b>html</b> test"

			err = userValidator.validate( _data )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 23 )
			should.exist( _data.active )
			_data.active.should.eql( false )
			_data.flagA.should.eql( false )
			_data.flagB.should.eql( true )
			should.exist( _data.comment )
			_data.comment.should.eql( "a html test" )
			done()
			return

		it "success min", ( done )->
			_data = { name: "John" }
			err = userValidator.validate( _data )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 42 )
			should.exist( _data.active )
			_data.active.should.eql( true )
			done()
			return

		it "missing required", ( done )->
			err = userValidator.validate( { email: "john@do.com", age: "23" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_REQUIRED_NAME" )
			err.field.should.eql( "name" )
			err.type.should.eql( "required" )
			err.statusCode.should.eql( 406 )
			err.customError.should.eql( true )
			err.should.instanceof( Error )
			should.exist( err.def )
			done()
			return

		it "invalid type", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", age: "23" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_NUMBER_AGE" )
			err.field.should.eql( "age" )
			err.type.should.eql( "number" )
			done()
			return

		it "invalid email", ( done )->
			err = userValidator.validate( { name: "John", email: "johndocom", age: 23 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_EMAIL_EMAIL" )
			err.field.should.eql( "email" )
			err.type.should.eql( "email" )
			done()
			return

		it "invalid enum", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", age: 23, tag: "X" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_ENUM_TAG" )
			done()
			return

		it "invalid timezone", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", timezone: "X" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_TIMEZONE_TIMEZONE" )
			done()
			return

		it "invalid timezone", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", timezone: "X" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_TIMEZONE_TIMEZONE" )
			done()
			return

		it "invalid subschema type", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", settings: { a: "a", b: "b" } } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_SETTINGS_NUMBER_B" )
			done()
			return

		it "invalid subschema required", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", settings: { b: "b" } } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_SETTINGS_REQUIRED_A" )
			done()
			return

		it "invalid object", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", props: "foo:bar" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_OBJECT_PROPS" )
			done()
			return

		it "invalid boolean", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", active: "NO" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_BOOLEAN_ACTIVE" )
			done()
			return

		it "failing number check", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_AGE" )
			done()
			return

		it "failing number check eq", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", checkA: 23 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_CHECKA" )
			done()
			return

		it "failing number check neq", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", checkB: 42 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_CHECKB" )
			done()
			return

		it "failing number regex", ( done )->
			err = userValidator.validate( { name: "John", sex: "X" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_REGEXP_SEX" )
			done()
			return
		
		it "failing string length too low", ( done )->
			err = userValidator.validate( { name: "Jo", email: "john@do.com", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_NAME" )
			done()
			return
		
		it "failing string length too high", ( done )->
			err = userValidator.validate( { name: "John", nickname: "johntheipsumdo", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_NICKNAME" )
			err.should.have.property( "def" )
				.and.have.property( "check" )
				.and.have.property( "value" )
				.and.eql( 10 )
			done()
			return
		
		it "failing string length neq - low", ( done )->
			err = userValidator.validate( { name: "John", type: "x", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_TYPE" )
			done()
			return
		
		it "failing string length neq - high", ( done )->
			err = userValidator.validate( { name: "John", type: "abc", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_TYPE" )
			err.type.should.eql( "length" )
			done()
			return
			
		it "failing with callback", ( done )->
			err = userValidator.validateCb { name: "John", type: "abc", age: 0 }, ( err )->
				should.exist( err )
				err.name.should.eql( "EVALIDATION_USER_LENGTH_TYPE" )
				err.type.should.eql( "length" )
				done()
				return
			return
		
		it "failing string", ( done )->
			errors = userValidator.validateMulti( { name: "x", type: "x", age: 0 } )
			should.exist( errors )
			errors.should.have.length( 3 )
			_map( errors, "field" ).should.containDeep(["name", "type", "age"])
			_map( errors, "name" ).should.containDeep(["EVALIDATION_USER_LENGTH_NAME", "EVALIDATION_USER_LENGTH_TYPE", "EVALIDATION_USER_CHECK_AGE"])
			done()
			return

		it "failing between too low", ( done )->
			err = userValidator.validate( { name: "John", type: "ab", money: 666 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_MONEY" )
			err.type.should.eql( "check" )
			done()
			return

		it "failing between too high", ( done )->
			err = userValidator.validate( { name: "John", type: "ab", money: 6666 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_MONEY" )
			err.type.should.eql( "check" )
			done()
			return

		it "between bottom boundary", ( done )->
			err = userValidator.validate( { name: "John", type: "ab", money: 1000 } )
			should.not.exist( err )
			done()
			return

		it "between bottom boundary", ( done )->
			err = userValidator.validate( { name: "John", type: "ab", money: 5000 } )
			should.not.exist( err )
			done()
			return
		
		it "array: wrong type", ( done )->
			err = userValidator.validate( { name: "John", list: 123 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_ARRAY_LIST" )
			err.type.should.eql( "array" )
			done()
			return
		
		it "array: between length too low", ( done )->
			err = userValidator.validate( { name: "John", list: [1], money: 5000 } )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_LIST" )
			err.type.should.eql( "length" )
			done()
			return
		
		it "array: between length top boundary", ( done )->
			err = userValidator.validate( { name: "John", list: [1,2], money: 5000 } )
			should.not.exist( err )
			done()
			return
	
		it "array: between length top boundary", ( done )->
			err = userValidator.validate( { name: "John", list: [1,2,3,4], money: 5000 } )
			should.not.exist( err )
			done()
			return
		
		it "array: between length too high", ( done )->
			err = userValidator.validate( { name: "John", list: [1,2,3,4,5], money: 5000 } )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_LIST" )
			err.type.should.eql( "length" )
			done()
			return
		
		return
		
	describe 'Single Key -', ->
		it "successfull validate a single key", ( done )->
			res = userValidator.validateKey( "name", "John" )
			should.exist( res )
			res.should.not.instanceof( Error )
			res.should.eql( "John" )
			done()
			return
		
		it "failing validate a single key", ( done )->
			res = userValidator.validateKey( "name", "J." )
			should.exist( res )
			res.should.instanceof( Error )
			res.name.should.eql( "EVALIDATION_USER_LENGTH_NAME" )
			res.type.should.eql( "length" )
			done()
			return
		
		it "validate a unkown key", ( done )->
			res = userValidator.validateKey( "wat", "J." )
			should.not.exist( res )
			done()
			return
			
		it "generate default", ( done )->
			res = userValidator.validateKey( "age", null )
			should.exist( res )
			res.should.not.instanceof( Error )
			res.should.eql( 42 )
			done()
			return
			
		it "strip html", ( done )->
			res = userValidator.validateKey( "comment", "<b>abc</b><div class=\"test\">XYZ</div>" )
			should.exist( res )
			res.should.not.instanceof( Error )
			res.should.eql( "abcXYZ" )
			done()
			return
		return
		
	describe 'Check Array content -', ->
		
		userValidatorArray = new Schema([
				key: "id",
				required: true,
				type: "number"
			,
				key: "name",
				type: "string"
				check:
					operand: "btw"
					value: [4,20]
			,
				key: "email",
				type: "email"
			,
				key: "age"
			,
				key: "foo"
				type: "number"
				default: 42
		], { name: "user" })
		
		it "successfull validate", ( done )->
			_data = [ 123, "John", "john@do.com", 23 ]
			err = userValidatorArray.validate( _data, { type: "create" } )
			should.not.exist( err )
			should.exist( _data[3] )
			_data[3].should.eql( 23 )
			_data[4].should.eql( 42 )
			should.not.exist( _data[5] )
			done()
			return
		
		it "missing id", ( done )->
			_data = [ null, "John", "john@do.com", 23 ]
			err = userValidatorArray.validate( _data, { type: "create" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_REQUIRED_ID" )
			err.def.idx.should.eql( 0 )
			done()
			return
			
		it "invalid name", ( done )->
			_data = [ 45, "Doe", "john@do.com", 23 ]
			err = userValidatorArray.validate( _data, { type: "create" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_NAME" )
			err.def.idx.should.eql( 1 )
			done()
			return
		
		return
	
	describe 'Custom functions -', ->
		
		fnSkipId = ( key, val, data, options )->
			return options.type isnt "create"
		
		fnDefaultAge = ( key, val, data, options )->
			return data.name.length * ( options.factor or 13 )
		
		fnDefaultName = ( key, val, data, options )->
			return "autogen-" + data.id
			
		userValidatorFn = new Schema({
			id:
				required: true,
				type: "number",
				fnSkip: fnSkipId
			name:
				type: "string",
				default: fnDefaultName
			email:
				type: "email"
			age:
				default: fnDefaultAge
		}, { name: "user" })
		
		
		it "successfull validate with fnSkip", ( done )->
			_data = { id: 123, name: "John", email: "john@do.com", age: 23 }
			err = userValidatorFn.validate( _data, { type: "create" } )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 23 )
			done()
			return
			
		it "failing validate with fnSkip", ( done )->
			_data = { name: "John", email: "john@do.com" }
			err = userValidatorFn.validate( _data, { type: "create" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_REQUIRED_ID" )
			done()
			return
		
		it "success validate with fnSkip with differnt type", ( done )->
			_data = { name: "John", email: "john@do.com" }
			err = userValidatorFn.validate( _data, { type: "update" } )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 52 )
			done()
			return
		
		it "success modify age default", ( done )->
			_data = { name: "John", email: "john@do.com" }
			err = userValidatorFn.validate( _data, { type: "update", factor: 23 } )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 92 )
			done()
			return
		
		it "success modify name default", ( done )->
			_data = { id: 123, email: "john@do.com" }
			err = userValidatorFn.validate( _data, { type: "create" } )
			should.not.exist( err )
			
			_expName = "autogen-123"
			_data.should.have.property( "age" )
				.and.eql( _expName.length * 13 )
			_data.should.have.property( "name" )
				.and.eql( _expName )
			done()
			return
	return
