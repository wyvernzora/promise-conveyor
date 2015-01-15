should = require('chai').should()
conveyor = require('../dist/conveyor.js')

describe 'Conveyor.Error class', ->

  describe '#constructor() without details object', ->
    error = new conveyor.Error('Test message.')

    it 'should create an Error object.', ->
      error.should.be.an.instanceof(Error)
      error.should.be.an.instanceof(conveyor.Error)

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message.')

    it 'toString() should behave correctly.', ->
      error.toString().should.equal('Test message.')

  describe '#constructor() with a plain details object', ->
    error = new conveyor.Error('Test message.', prop: 'value')

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message.')

  describe '#constructor() with a details object that overrides toString()', ->
    error = new conveyor.Error('Test message.', toString: -> 'Another test.')

    it 'should have the correct message.', ->
      error.should.have.property('message').that.equals('Test message. (Another test.)')
