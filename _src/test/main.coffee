should = require('should')

Schema = require( "../." ) 

userValidator = null
settingsValidator = null

describe "----- obj-schema TESTS -----", ->

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

			"comment": 
				type: "string"
				striphtml: true

			"tag": 
				type: "enum"
				values: [ "A", "B", "C" ]

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

	describe 'Main Tests', ->

		it "success", ( done )->
			_data = 
				name: "John"
				nickname: "johndoe"
				type: "ab"
				email: "john@do.com"
				sex: "M"
				tag: "A"
				age: 23
				timezone: "CET"
				settings: { a: "foo" }
				props: { foo: "bar" }
				active: false
				checkA: 42
				checkB: 23
				comment: "a <b>html</b> test"

			err = userValidator.validate( _data )
			should.not.exist( err )
			should.exist( _data.age )
			_data.age.should.eql( 23 )
			should.exist( _data.active )
			_data.active.should.eql( false )
			should.exist( _data.comment )
			_data.comment.should.eql( "a  html  test" )
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

		it "faling number check", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_AGE" )
			done()
			return

		it "faling number check eq", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", checkA: 23 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_CHECKA" )
			done()
			return

		it "faling number check neq", ( done )->
			err = userValidator.validate( { name: "John", email: "john@do.com", checkB: 42 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_CHECK_CHECKB" )
			done()
			return

		it "faling number regex", ( done )->
			err = userValidator.validate( { name: "John", sex: "X" } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_REGEXP_SEX" )
			done()
			return
		
		it "faling string length too low", ( done )->
			err = userValidator.validate( { name: "Jo", email: "john@do.com", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_NAME" )
			done()
			return
		
		it "faling string length too high", ( done )->
			err = userValidator.validate( { name: "John", nickname: "johntheipsumdo", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_NICKNAME" )
			done()
			return
		
		it "faling string length neq - low", ( done )->
			err = userValidator.validate( { name: "John", type: "x", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_TYPE" )
			done()
			return
		
		it "faling string length neq - high", ( done )->
			err = userValidator.validate( { name: "John", type: "abc", age: 0 } )
			should.exist( err )
			err.name.should.eql( "EVALIDATION_USER_LENGTH_TYPE" )
			err.type.should.eql( "length" )
			done()
			return

		return
	return
