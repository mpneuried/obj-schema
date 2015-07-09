"use strict";

var Schema = require( "./." );

var skipId = function( key, val, data, options ){
    // skip the id validation if the options, which defines a validation type, is `create`.
    if( options === "create" ){
        return false;
    }
    return true;
};

var defaultName = function( key, val, data, options ){
    return "autogen-" + data.id;
};

var uservalidator = new Schema( {
    id: {
        required: true,
        type: "number",
        fnSkip: skipId
    },
    name: {
        type: "string",
        default: defaultName
    },
    email: {
        type: "email"
    }
}, { name: "user" });

function userCreate( data, cb ){
    var err = uservalidator.validate( data, "create" );
    if( err ){
        cb( err );
    }else{
        // do you db insert here
        cb( null, data );
    }
}

function userUpdate( id, data, cb ){
    var err = uservalidator.validate( data, "update" );
    if( err ){
        cb( err );
    }else{
        // do you db update here
        cb( null, id, data );
    }
}

userCreate( { name: "John", email: "john@do.com" }, function( err, data ){
    console.log( err, data );
    // -> err.name = EVALIDATION_USER_REQUIRED_ID
});

userCreate( { id: 42, email: "john@do.com" }, function( err, data ){
    console.log( err, data );
    // -> data.name = "autogen-42"
});

userUpdate( 23, { name: "John", email: "john@do.com" }, function( err, id, data ){
    console.log( err, id, data );
    // -> err = null
});
