chai = require('chai')
assert = chai.assert
should = chai.should()
expect = chai.expect
pconv = require('../dist/conveyor.js')


describe 'pconv.Conveyor class', ->

  describe '#constructor()', ->
    conveyor = new pconv.Conveyor(prop: 'value')

    it 'should create a pconv.Conveyor object', ->
      conveyor.should.be.an.instanceof(pconv.Conveyor)

    it 'should have the correct data property when one is specified', ->
      conveyor.should.have.deep.property('data.prop').that.equals('value')

    it 'should not throw error when data property is null or undefined', ->
      conv0 = new pconv.Conveyor(null)
      conv1 = new pconv.Conveyor(undefined)

  describe 'running plugins', ->

    it 'should correctly run a simple sequence', (done) ->
      result = []
      new pconv.Conveyor()
        .then (pconv 'step 0', -> result.push 0)()
        .then (pconv 'step 1', -> result.push 1)()
        .then (pconv 'step 2', -> result.push 2)()
        .then (pconv 'step 3', -> result.push 3)()
        .promise
          .then ->
            expect(result).to.be.deep.equal([0, 1, 2, 3])
            done()
          .catch (error) ->
            done(error)

    it 'should correctly detect and handle errors in sequence', (done) ->
      result = []
      new pconv.Conveyor()
        .then (pconv 'step 0', -> result.push 0)()
        .then (pconv 'step 1', -> result.push 1)()
        .then (pconv 'step 2', -> throw new Error('ERROR!'))()
        .then (pconv 'step 3', -> result.push 3)()
        .promise
          .then -> done(new Error('Conveyor did not terminate on error!'))
          .catch (error) ->
            expect(result).to.be.deep.equal([0, 1])
            expect(error).to.be.an.instanceof(Error)
            done()

    it 'should correctly detect currently running plugin', (done) ->
      new pconv.Conveyor()
        .then (pconv 'step 0', -> expect(@pipeline.current).to.equal('step 0'))()
        .then (pconv 'step 1', -> expect(@pipeline.current).to.equal('step 1'))()
        .then (pconv 'step 2', -> expect(@pipeline.current).to.equal('step 2'))()
        .then (pconv 'step 3', -> expect(@pipeline.current).to.equal('step 3'))()
        .promise
          .then -> done()
          .catch (error) -> done(error)

  describe 'data piping', ->

    it 'should correctly access input data by config', (done) ->
      result = []
      new pconv.Conveyor(prop: 0)
        .then (pconv 'step 0', (val) -> result.push val)(input: 'prop')
        .promise
          .then ->
            expect(result).to.be.deep.equal([0])
            done()
          .catch (error) ->
            done(error)

    it 'should correctly assign output data by config', (done) ->
      conveyor = new pconv.Conveyor()
      conveyor
        .then (pconv 'step 0', -> return 1)(output: 'prop')
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(1)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly infer single value input/outputs', (done) ->
      conveyor = new pconv.Conveyor(prop: 0)
      conveyor
        .then (pconv 'step 0', (val) -> return val + 1)(input: 'prop')
        .then (pconv 'step 1', (val) -> return val + 1)()
        .then (pconv 'step 2', (val) -> return val + 1)()
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(3)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly handle multiple input values', (done) ->
      conveyor = new pconv.Conveyor(a: 1, b: 2)
      conveyor
        .then (pconv 'step 0', (a, b) -> return a + b)(input: ['a', 'b'], output: 'prop')
        .promise
          .then ->
            expect(conveyor.data).to.have.property('prop').that.equals(3)
            done()
          .catch (error) ->
            done(error)

    it 'should not output anything when input isn\'t single value and output is unspecified', (done) ->
      conveyor = new pconv.Conveyor(a: 1, b: 2)
      conveyor
        .then (pconv 'step 0', (a, b) -> return a + b)(input: ['a', 'b'])
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly pass in the data object for null input', (done) ->
      conveyor = new pconv.Conveyor(a: 1, b: 2)
      conveyor
        .then (pconv 'step 0', (data) -> expect(data).to.be.deep.equal(a: 1, b: 2))(input: null)
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly pass out the data for null output', (done) ->
      conveyor = new pconv.Conveyor(a: 1, b: 2)
      conveyor
        .then (pconv 'step 0', -> b: 3, c: 4)(output: null)
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 3, c: 4)
            done()
          .catch (error) ->
            done(error)

    it 'should correctly infer null input for the first plugin if input is not specified', (done) ->
      conveyor = new pconv.Conveyor(a: 1, b: 2)
      conveyor
        .then (pconv 'step 0', (arg) -> expect(arg).to.be.equal(conveyor.data))()
        .promise
          .then ->
            expect(conveyor.data).to.be.deep.equal(a: 1, b: 2)
            done()
          .catch (error) ->
            done(error)
