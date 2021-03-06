obj-schema
============

[![Build Status](https://secure.travis-ci.org/mpneuried/obj-schema.png?branch=master)](http://travis-ci.org/mpneuried/obj-schema)
[![Windows Tests](https://img.shields.io/appveyor/ci/mpneuried/obj-schema.svg?label=WindowsTest)](https://ci.appveyor.com/project/mpneuried/obj-schema)
[![Coveralls Coverage](https://img.shields.io/coveralls/mpneuried/obj-schema.svg)](https://coveralls.io/github/mpneuried/obj-schema)

[![Deps Status](https://david-dm.org/mpneuried/obj-schema.png)](https://david-dm.org/mpneuried/obj-schema)
[![npm version](https://badge.fury.io/js/obj-schema.png)](http://badge.fury.io/js/obj-schema)
[![npm downloads](https://img.shields.io/npm/dt/obj-schema.svg?maxAge=2592000)](https://nodei.co/npm/obj-schema/)

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

**Array Version**

```js
	var Schema = require( "obj-schema" );

	uservalidator = new Schema( [{
			key: "name",
			type: "string",
			required: true
		},{
			key: "email",
			type: "email"
		},{
			key: "age",
			type: "number",
			default: 42
		}]
	}, { name: "user" });

	console.log( uservalidator.validate( [ "John", "john@do.com", 23 ] ) ); // null
	console.log( uservalidator.validate( [ "John", "john@do.com", "23" ] ) ); // Error[`EVALIDATION_USER_NUMBER_AGE`: The value in `age` has to be a number]
```


The schema will check the given object against the defined rules and returns `null` on success or an error if the object is not valid.
If the schema is configured to change the values it'll do this directly on the object reference.


**Config** 

- **schema**: *( `Object|Array` required )* : The schema for validation
	- **schema[ {key} ]** : *( `Object` )* Every key will be validated by the given config. See section **Schema-Types**
- **options** *( `Object` optional )* The configuration object
	- **options.name** : *( `String` optional: default = `data` )* A name used to inject it to the error name.
	- **options.customerror** : *( `Function` optional: default = `error` )* A custom error function to generate your own error objects.
	> This method will be bind to the Schema istance, so you can use all methods of obj-schema.

## Schema-Types

#### General

- **type**: *( `String` )*: The data type for detailed validation. All availible types will be described below.
- **required**: *( `Boolean` )*: This key is required
- **nullAllowed**: *( `Boolean`, default: `false` )*: If the key is `required: true` you can allow `null` as valid value.
- **default**: *( `Any|Function` )*: A default value or a function to generate the default. This function will receive the arguments `( key, val, data, options )`. `data` = the whole object to validate; `def` = the current schema type config.
- **foreignReq**: *( `String[]` )*: Is only valid if the keys within this list exists
- **fnSkip**: *( `Function` )*: A function to determine if a validation should be skipped. As a return it expects a boolean. The arguments passed to the function are `( key, val, data, options )`.

#### `number`

Check if the value is of type `number`

- **check**: *( `Object` )*: A configuration to check the given value against a predefined value
	- **check.operand**: *( `String` enum: `eq`, `==`, `=`, `neq`, `!=`, `gt`, `>`, `gte`, `>=`, `lt`, `<`, `lte`, `<=`, `between`, `btw`, `><` )*: the operand to use against.
	- **check.value**: *( `Number|Array` )* The value to check against. In case of a between an array size two is required (eg. [{low},{high}])

#### `string`

Check if the value is of type `string`

- **regexp**: *( `RegExp` )*: A regular expression to check against the value
- **sanitize**: *( `Boolean` )*: sanitize this sting
- **striphtml**: *( `Boolean|Array` )*: strip all html tags out of the string. You can use an array to define the allowed tags.
- **trim**: *( `Boolean` )*: trim the string

- **check**: *( `Object` )*: A configuration to check the given string. length against a predefined value
	- **check.operand**: *( `String` enum: `eq`, `==`, `=`, `neq`, `!=`, `gt`, `>`, `gte`, `>=`, `lt`, `<`, `lte`, `<=`, `between`, `btw`, `><` )*: the operand to use against.
	- **check.value**: *( `Number|Array` )* The value to check against. In case of a between an array size two is required (eg. [{low},{high}])

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

### `.validate( object[, options] )`

Validate the data obj and stop on the first error

**Arguments**

* **`object`** : *( `Object` required )*: The object to validate against the schema
* **`options`** : *( `Any` optional )*: options that will be passed to the schema functions `fnSkip` and `default`. See `example.js`.

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

**Example**

```js
	function create( data, cb ){
		var error = uservalidator.validate( data )
		if( error ){
			// handle the error
		}else{{
			// do your stuff
		}
	}
```

### `.validate( object[, options] )`

Validate the data obj and stop on the first error

**Arguments**

* **`object`** : *( `Object` required )*: The object to validate against the schema
* **`options`** : *( `Any` optional )*: options that will be passed to the schema functions `fnSkip` and `default`. See `example.js`.

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

**Example**

```js
	function create( data, cb ){
		var error = uservalidator.validate( data )
		if( error ){
			// handle the error
		}else{{
			// do your stuff
		}
	}
```


### `.validateKey( key, value[, options] )`

Validate olny one single key

**Arguments**

* **`key`** : *( `String` required )*: The schema key to validate
* **`value `** : *( `Any` required )*: the data to validate
* **`options`** : *( `Any` optional )*: options that will be passed to the schema functions `fnSkip` and `default`. See `example.js`.

**Return**

**Example**

```js
	function create( data, cb ){
		var errors = uservalidator.validateMulti( data )
		if( errors ){
			// handle the array of errors
		}else{{
			// do your stuff
		}
	}
```

*( Null|[]Error )*: Returns `null` on success and an array of errors if the validation failed. 

### `.keys()`

Returns an array of all keys within the schema.

**Return**

*( Array )*: Schema keys.

### `.validateCb( object[, options][, cb] )`

A helper method to use it with a callback. 

- If `cb = null` a error will be thrown
- If `cb` is a function the error will be returned as first argument. **On success the callback will not executed!**
- If `cb` is not a function ( like a boolean or string ) it'll just returnes the error

**Arguments**

* **`object`** : *( `Object` required )*: The object to validate against the schema
* **`cb`** : *( `Object` required )*: The object to validate against the schema
* **`options`** : *( `Any` optional )*: options that will be passed to the schema functions `fnSkip` and `default`. See `example.js`.

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

**Example**

```js
	function create( data, cb ){
		uservalidator.validateCb( data, function( err, data ){
			// do your stuff
		});
	}
```

### `.error( errtype, key, def, opt )`

The internaly used method to generate the reponse error obj. 
You can define your own error obj. creator by defining a custom function in `options.customerror`.

**Arguments**

* **`errtype`** : *( `String` required )*: The error type. This could be one of the Schema-Types
* **`key`** : *( `String` required )*: The key that doues not match
* **`def`** : *( `Object` required )*: The schema definition of the key
* **`opt`** : *( `Object` required )*: additional informations to generate the data

**Return**

*( Null|Error )*: Returns `null` on success and an error if the validation failed. 

**Example**

```js
	function create( data, cb ){
		uservalidator.validateCb( data, function( err, data ){
			// do your stuff
		});
	}
```

## Error

This module uses a custom Error ( `ObjSchemaError` ) to add some meta data to the validation error response.

**Arguments**

* **`name`** : *( `String` )*: The error name. Format: `EVALIDATION_{options.name}_{error-type}_{object-key}` E.g. `EVALIDATION_USER_REQUIRED_NAME`
* **`message`** : *( `String` )*: A human friendly error message. E.g. `Please define the value 'name'`
* **`stack`** : *( `String` )*: A error stack trace
* **`customError`** : *( `Boolean` )*: A flag to define this error as a custom error. This is always `true`.
* **`statusCode`** : *( `Number` )*: A http status code to use in http response
* **`def`** : *( `Object` )*: the field definition. E.g. `{ type: "string", required: true }`
* **`check`** : *( `Object` )*: if it's an error type `check` this is the relevant data. `{ operand: "gte", value: 23 }`. The operand will be reduced to the values `eq,neq,gt,gte,lt,lte,between`.
* **`type`** : *( `String` )*: The objects error type.  
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
* **`field`** : *( `String` )*: The objects field the error occurred in. E.g. `name`
* **`path`** : *( `String` )*: A string representing the path through the sub schemas.  
If the error occurred in the root schema the path will not exist  
The keys are seperated by a `/`. E.g. `address/phones/mobile`

## Advanced example

This example in `example.js`. shows how to use the custom functions.

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

## Breaking Changes

### Upgrade to `1.x`

The arguments for the `default` function changed.
A migration is only necessary if you used functions to calc the `default` on the fly.

**Old:**

Arguments: `( data, def )`

```js

var defaultName = function( data, def ){
    return "autogen-" + data.id;
};

var uservalidator = new Schema( {
    name: {
        type: "string",
        default: defaultName
    }
}, { name: "user" });
```

**New:**

Arguments: `( key, val, data, options )`

```js

var defaultName = function( key, val, data, options ){
    return "autogen-" + data.id;
};

var uservalidator = new Schema( {
    name: {
        type: "string",
        default: defaultName
    }
}, { name: "user" });

```

## TODO

- add custom checks or plugins: this is useful to remove moment-timezone from the dependencies. So a core and plugin concept would be useful to add the checks `timezone`, `sanitizer` and `htmlstrip` 

## Release History

|Version|Date|Description|
|:--:|:--:|:--|
|1.6.2|2017-11-15|fixed dependency licence issue by replacing the `js-striphtml` with `striptags`; updated dev dependencies|
|1.6.1|2017-02-20|fixed failed build/publish|
|1.6.0|2017-02-20|added feature to allow `null` for required values if `nullAllowed: true` |
|1.5.3|2017-02-09|fixed: a array was accepted as type "object" |
|1.5.2|2017-02-09|fixed: pass of missing customerror option to sub schemas|
|1.5.1|2017-02-09|added path to error object to show the path through sub-schemas and optimized the generated name for sub schemas|
|1.5.0|2017-02-08|it's now possible to nest a sub-schema direct within the parent as `schema: { ... } / [ ... ]`; Optimized tests for 100% codeverage|
|1.4.0|2016-11-14|validate the basic input object for a object/array|
|1.3.0|2016-11-11|added option `customerror` to be able to create your own error objects|
|1.2.3|2016-10-07|Optimized sub-schema data type validation to check for object/array; use coveralls directly with coffee|
|1.2.2|2016-10-07|Added badges and coveralls report|
|1.2.0|2016-10-07|added length checks to array type; Made it possible to use an Array as schema to check the elements of an array; Optimized dev env.|
|1.1.3|2016-03-08|updated dependencies. Especially lodash to version 4|
|1.1.2|2015-07-31|removed dependency `mpbasic` for a smaller footprint within browserify|
|1.1.1|2015-07-14|reduced error check operand to the values `eq,neq,gt,gte,lt,lte,between`|
|1.1.0|2015-07-14|added check mode `between/btw/><` to check a string length or numeric value.|
|1.0.0|2015-07-09|added method `.validateKey()` to validate only one key. Added `fnSkip` definition method. Added optional options, that will be passed to the functions `fnSkip` and `default`. Changed arguments of default function. |
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
