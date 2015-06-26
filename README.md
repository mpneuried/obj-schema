obj-schema
============

[![Build Status](https://secure.travis-ci.org/mpneuried/obj-schema.png?branch=master)](http://travis-ci.org/mpneuried/obj-schema)
[![Build Status](https://david-dm.org/mpneuried/obj-schema.png)](https://david-dm.org/mpneuried/obj-schema)
[![NPM version](https://badge.fury.io/js/obj-schema.png)](http://badge.fury.io/js/obj-schema)

Simple module to validate an object by a predefined schema

[![NPM](https://nodei.co/npm/obj-schema.png?downloads=true&stars=true)](https://nodei.co/npm/obj-schema/)

*Written in coffee-script*

**INFO: all examples are written in coffee-script**

## Install

```
  npm install obj-schema
```

## Initialize

```js
	var Schema = require( "obj-schema" );

	uservalidator = new Schema( {
		"name": {
			type: "string",
			required: true
		},
		"email": {
			type: "email"
		},
		"age": {
			type: "number",
			default: 42
		}
	}, { name: "user" });

	console.log( uservalidator.validate( { name: "John", email: "john@do.com", age: 23 } ) ); // null
	console.log( uservalidator.validate( { name: "John", email: "john@do.com", age: "23" } ) ); // Error[`EVALIDATION_USER_NUMBER_AGE`: The value in `age` has to be a number]
```

The schema will check the given object against the defined rules and returns `null` on success or an error if the object is not valid.
If the schema is configured to change the values it'll do this directly on the object reference.


**Config** 

- **schema**: *( `Object` required )* : The schema for validation
	- **schema[ {key} ]** : *( `Object` )* Every key will be validated by the given config. See section **Schema-Types**
- **options** *( `Object` optional )* The configuration object
	- **options.name** : *( `String` optional: default = `data` )* A name used to inject it to the error name.

## Schema-Types

#### General

- **type**: *( `String` )*: The data type for detailed validation. All availible types will be described below.
- **required**: *( `Boolean` )*: This key is required
- **default**: *( `Any|Function` )*: A default value or a function to generate the default. This function will receive the arguments `( data, def )`. `data` = the whole object to validate; `def` = the current schema type config.
- **foreignReq**: *( `String[]` )*: is only valid if the keys within this list exists


#### `number`

Check if the value is of type `number`

- **check**: *( `Object` )*: A configuration to check the given value against a predefined value
	- **check.operand**: *( `String` enum: `eq`, `==`, `=`, `neq`, `!=`, `gt`, `>`, `gte`, `>=`, `lt`, `<`, `lte`, `<=` )*: the operand to use against
	- **check.value**: *( `Number` )* The value to check against

#### `string`

Check if the value is of type `string`

- **regexp**: *( `RegExp` )*: A regular expression to check against the value
- **sanitize**: *( `Boolean` )*: sanitize this sting
- **striphtml**: *( `Boolean|Array` )*: strip all html tags out of the string. You can use an array to define the allowed tags.
- **trim**: *( `Boolean` )*: trim the string

- **check**: *( `Object` )*: A configuration to check the given string. length against a predefined value
	- **check.operand**: *( `String` enum: `eq`, `==`, `=`, `neq`, `!=`, `gt`, `>`, `gte`, `>=`, `lt`, `<`, `lte`, `<=` )*: the operand to use against
	- **check.value**: *( `Number` )* The string length to check against

#### `boolean`

Check if the value is of type `boolean`

#### `array`

Check if the value is of type `array`

#### `object`

Check if the value is of type `object`

#### `email`

Check if the value is of type `string` and is a valid email

#### `enum`

Check if the value is of type `string` and is one of the configured elements

- **values**: *( `String[]` )*: An array of strings that are valid

#### `schema`

Check if the value is of type `object` and check against another given schema

- **schema**: *( `ObjSchema` )*: A additional schema

#### `timezone`

Check if the value is of type `string` and is a valid [moment timezone](http://momentjs.com/timezone/)

## Methods

### `.validate( object )`

Validate the data obj and stop on the first error

**Arguments**

* `object` : *( `Object` required )*: The object to validate against the schema

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

### `.validateMulti( object )`

Validate the data obj and return an array of errors

**Arguments**

* `object` : *( `Object` required )*: The object to validate against the schema

**Return**

*( Null|Error[] )*: Returns `null` on success and an array of errors if the validation failed. 

### `.keys()`

Returns an array of all keys within the schema.

**Return**

*( Array )*: Schema keys.

### `.validateCb( object[, cb] )`

A helper method to use it with a callback. 

- If `cb = null` a error will be thrown
- If `cb` is a function the error will be returned as first argument. **On success the callback will not executed!**
- If `cb` is not a function ( like a boolean or string ) it'll just returnes the error

**Arguments**

* `object` : *( `Object` required )*: The object to validate against the schema
* `cb` : *( `Object` required )*: The object to validate against the schema

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

**Example**

```js
	function create( data, cb ){
		if( !uservalidator( data, cb )){
			// do your stuff
		}
	}
```

## Error

This module uses a custom Error ( `ObjSchemaError` ) to add some meta data to the validation error response.

**Arguments**

* `name` : *( `String` )*: The error name. Format: `EVALIDATION_{options.name}_{error-type}_{object-key}` E.g. `EVALIDATION_USER_REQUIRED_NAME`
* `message` : *( `String` )*: A human friendly error message. E.g. `Please define the value 'name'`
* `stack` : *( `String` )*: A error stack trace
* `customError` : *( `Boolean` )*: A flag to define this error as a custom error. This is always `true`.
* `statusCode` : *( `Number` )*: A http status code to use in http response
* `def` : *( `Object` )*: the field definition. E.g. `{ type: "string", required: true }`
* `type` : *( `String` )*: The objects error type.  
Possible error types:
    * `required` : Is required and not set
    * `number` : Is not a number
    * `string` : Is not a string
    * `boolean` : Is not boolean
    * `array` : Is not an array
    * `object` : Is not a object
    * `email` : Is not a email
    * `timezone` : Is not a moment timezone. see [moment timezone](http://momentjs.com/timezone/)
    * `regexp` : Doesn't match the regular expression
    * `enum` : Is not within the given list
    * `length` : The string length  isn't within the defined boundaries
    * `check` : The numeric value isn't within the defined boundaries
* `field` : *( `String` )*: The objects field the error occurred in. E.g. `name`

## Testing

**Node.js**

To run the the node tests just call `grunt test` or `npm test`.

**Browser**

The browser test to use this module with browserify can simply executed with **[browserify-test](https://github.com/alekseykulikov/browserify-test)**

install: `npm install -g browserify-test`.

To test in browser just execute the following command within the project folder
`browserify-test --watch ./test/main.js`
Then follow the instructions ...

**Headless**

To test headless yo have to use is with phantomjs

install: `npm install -g phantomjs`

execute test: `browserify-test ./test/main.js`


## Release History
|Version|Date|Description|
|:--:|:--:|:--|
|0.3.0|2015-06-26|added method `.validateMulti()` retrieve all validation errors at once|
|0.2.0|2015-06-25|Changed strip tags module to be able to use this module with browserify|
|0.1.2|2015-06-19|Added field definition (key `def`) to error.|
|0.1.1|2015-06-18|Better validation error with custom fields. optimized readme.|
|0.1.0|2015-06-17|Added string trim, added string length checks|
|0.0.1|2015-01-29|Initial version|

[![NPM](https://nodei.co/npm-dl/obj-schema.png?months=6)](https://nodei.co/npm/obj-schema/)

> Initially Generated with [generator-mpnodemodule](https://github.com/mpneuried/generator-mpnodemodule)

## Other projects

|Name|Description|
|:--|:--|
|[**rsmq**](https://github.com/smrchy/rsmq)|A really simple message queue based on Redis|
|[**rsmq-worker**](https://github.com/mpneuried/rsmq-worker)|Helper to simply implement a worker [RSMQ ( Redis Simple Message Queue )](https://github.com/smrchy/rsmq).|
|[**redis-notifications**](https://github.com/mpneuried/redis-notifications)|A redis based notification engine. It implements the rsmq-worker to savely create notifications and recurring reports|
|[**node-cache**](https://github.com/tcs-de/nodecache)|Simple and fast NodeJS internal caching. Node internal in memory cache like memcached.|
|[**redis-sessions**](https://github.com/smrchy/redis-sessions)|An advanced session store for NodeJS and Redis|
|[**connect-redis-sessions**](https://github.com/mpneuried/connect-redis-sessions)|A connect or express middleware to simply use the [redis sessions](https://github.com/smrchy/redis-sessions). With [redis sessions](https://github.com/smrchy/redis-sessions) you can handle multiple sessions per user_id.|
|[**systemhealth**](https://github.com/mpneuried/systemhealth)|Node module to run simple custom checks for your machine or it's connections. It will use [redis-heartbeat](https://github.com/mpneuried/redis-heartbeat) to send the current state to redis.|
|[**task-queue-worker**](https://github.com/smrchy/task-queue-worker)|A powerful tool for background processing of tasks that are run by making standard http requests.|
|[**soyer**](https://github.com/mpneuried/soyer)|Soyer is small lib for serverside use of Google Closure Templates with node.js.|
|[**grunt-soy-compile**](https://github.com/mpneuried/grunt-soy-compile)|Compile Goggle Closure Templates ( SOY ) templates inclding the handling of XLIFF language files.|
|[**backlunr**](https://github.com/mpneuried/backlunr)|A solution to bring Backbone Collections together with the browser fulltext search engine Lunr.js|

## The MIT License (MIT)

Copyright © 2015 M. Peter, http://www.tcs.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
