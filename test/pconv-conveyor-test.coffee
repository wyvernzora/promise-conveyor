chai = require('chai')
assert = chai.assert
should = chai.should()
expect = chai.expect
Conveyor = require('../dist/conveyor.js')


describe 'Conveyor class', ->

  describe '#constructor()', ->
    conveyor = new Conveyor(prop: 'value')

    it 'should create a Conveyor object', ->
      conveyor.should.be.an.instanceof(Conveyor)

    it 'should have the correct data property when one is specified', ->
      conveyor.should.have.deep.property('data.prop').that.equals('value')

    it 'should not throw error when data property is null or undefined', ->
      conv0 = new Conveyor(null)
      conv1 = new Conveyor(undefined)

  describe 'running plugins', ->

    it 'should correctly run a simple sequence', (done) ->
      result = []
      new Conveyor()
        .then -> result.push 0
        .then -> result.push 1
        .then -> result.push 2
        .then -> result.push 3
        .promise
          .then ->
            expect(result).to.be.deep.equal([0, 1, 2, 3])
            done()
          .catch (error) ->
            done(error)

    it 'should correctly detect and handle errors in sequence', (done) ->
      result = []
      new Conveyor()
        .then -> result.push 0
        .then -> result.push 1
        .then -> throw new Error('ERROR!')
        .then -> result.push 3
        .promise
          .then -> done(new Error('Conveyor did not terminate on error!'))
          .catch (error) ->
            expect(result).to.be.deep.equal([0, 1])
            expect(error).to.be.an.instanceof(Error)
            done()

    it 'should correctly panic', (done) ->
      result = []
      new Conveyor()
        .then -> result.push 0
        .then -> result.push 1
        .then -> @conveyor.panic('Test Panic!')
        .then -> result.push 3
        .promise
          .then -> done(new Error('Conveyor did not terminate on error!'))
          .catch (error) ->
            expect(result).to.be.deep.equal([0, 1])
            expect(error).to.be.an.instanceof(Conveyor.Error)
            expect(error).to.have.property('message').that.equals('Test Panic!')
            expect(error).not.to.have.property('details')
            done()

  describe 'data piping', ->

    it 'should correctly access input data by config', (done) ->
      result = []
      new Conveyor(prop: 0)
        .then input: 'prop', (val) -> result.push val
        .promise
          .then ->
            expect(result).to.be.deep.equal([0])
            done()
          .catch (error) ->
            done(error)

    it 'should correctly assign output data by config', (done) ->
      conveyor = new Conveyor()
      conveyor
        .then output: 'prop', -> return 1
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(1)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly infer single value input/outputs', (done) ->
      conveyor = new Conveyor(prop: 0)
      conveyor
        .then input: 'prop', (val) -> val + 1
        .then (val) -> val + 1
        .then (val) -> val + 1
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(3)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly handle multiple input values', (done) ->
      conveyor = new Conveyor(a: 1, b: 2)
      conveyor
        .then input: ['a', 'b'], output: 'prop', (a, b) -> a + b
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(3)
            done()
          .catch (error) ->
            done(error)

    it 'should not output anything when input isn\'t single value and output is unspecified', (done) ->
      conveyor = new Conveyor(a: 1, b: 2)
      conveyor
        .then input: ['a', 'b'], (a, b) -> a + b
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly pass in the data object for null input', (done) ->
      conveyor = new Conveyor(a: 1, b: 2)
      conveyor
        .then input: null, (data) -> expect(data).to.be.deep.equal(a: 1, b: 2)
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly pass out the data for null output', (done) ->
      conveyor = new Conveyor(a: 1, b: 2)
      conveyor
        .then output: null, -> b: 3, c: 4
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 3, c: 4)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly infer null input for the first plugin if input is not specified', (done) ->
      conveyor = new Conveyor(a: 1, b: 2)
      conveyor
        .then (arg) -> expect(arg).to.be.equal(conveyor.data)
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)
