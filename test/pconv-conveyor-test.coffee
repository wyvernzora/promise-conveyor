should = require('chai').should()
pconv = require('../dist/conveyor.js')

describe 'pconv.Conveyor class', ->

  describe '#constructor() without data value', ->
    conveyor = new pconv.Conveyor(prop: 'value')

    it 'should create a pconv.Conveyor object', ->
      conveyor.should.be.an.instanceof(pconv.Conveyor)

    it 'should have the correct data property when one is specified', ->
      conveyor.should.have.deep.property('data.prop').that.equals('value')

    it 'should not throw error when data property is null or undefined', ->
      conv0 = new pconv.Conveyor(null)
      conv1 = new pconv.Conveyor(undefined)

  describe 'running plugins'
