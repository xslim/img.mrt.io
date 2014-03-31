global.chai = require 'chai'

global.should = global.chai.should()

global.chai.use require('chai-http')
global.chai.use require('chai-json-schema')


global.baseUrl = 'http://localhost:3000' #app