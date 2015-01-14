should = require('chai').should()
pconv = require('../dist/conveyor.js')

describe 'pconv.Error class', ->

  describe '#constructor() without details object', ->
    error = new pconv.Error('Plugin name', 'Test message.')

    it 'should create an Error object.', ->
      error.should.be.an.instanceof(Error)
      error.should.be.an.instanceof(pconv.Error)

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message.')

    it 'should have the correct plugin name.', ->
      error.should.have.property('pluginName').that.equals('Plugin name')

    it 'toString() should behave correctly.', ->
      error.toString().should.equal('Plugin [Plugin name] panic: Test message.')

  describe '#constructor() with a plain details object', ->
    error = new pconv.Error('Plugin name', 'Test message.', prop: 'value')

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message.')

  describe '#constructor() with a details object that overrides toString()', ->
    error = new pconv.Error('Plugin name', 'Test message.', toString: -> 'Another test.')

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message. (Another test.)')
