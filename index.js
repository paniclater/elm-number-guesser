// index.js
'use strict';
var styles = require('./index.css')
var Elm = require('./main.elm');
var mountNode = document.getElementById('elm-app');

// The third value on embed are the initial values for incomming ports into Elm
var app = Elm.Main.embed(mountNode);
