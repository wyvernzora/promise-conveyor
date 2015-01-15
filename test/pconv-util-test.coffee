should = require('chai').should()
expect = require('chai').expect
conveyor = require('../dist/conveyor.js')

util = conveyor.util

describe 'Conveyor.util', ->

  describe '#prop() for getting deep properties', ->

    test =
      a: 'a'
      b: 'b'
      c:
        a: 'c.a'
        b: 'c.b'
        c: 'c.c'
        d:
          a: 'c.d.a'
          b: 'c.d.b'
      d: [
        'd.0',
        'd.1',
        'd.2'
      ]
      e: [
        'e.0',
        'e.1',
        'e.2',
        { a: 'e[3].a', b: 'e[3].b'}
      ]

    it 'should correctly get non-deep basic property values', ->
      expect(util.prop test, 'a').to.be.equal('a')
      expect(util.prop test, 'b').to.be.equal('b')
      expect(util.prop test, 'z').to.be.undefined()

    it 'should correctly get deep basic property values', ->
      expect(util.prop test, 'c.a').to.be.equal('c.a')
      expect(util.prop test, 'c.d.a').to.be.equal('c.d.a')
      expect(util.prop test, 'z.a.b').to.be.undefined()
      expect(util.prop test, 'c.z').to.be.undefined()

    it 'should corretly get properties whose value is an object', ->
      expect(util.prop test, 'c.d').to.be.deep.equal(a: 'c.d.a', b: 'c.d.b')

    it 'should correctly get properties whose value is an array', ->
      expect(util.prop test, 'd').to.be.deep.equal(['d.0', 'd.1', 'd.2'])

    it 'should correctly get array items using both index notations', ->
      expect(util.prop test, 'e[0]').to.be.equal('e.0')
      expect(util.prop test, 'e.0').to.be.equal('e.0')
      expect(util.prop test, 'e[9]').to.be.undefined()

    it 'should correctly get properties of objects inside arrays', ->
      expect(util.prop test, 'e[3].a').to.be.equal('e[3].a')
      expect(util.prop test, 'e.3.b').to.be.equal('e[3].b')

  describe '#prop() for setting deep properties', ->

    it 'should correctly set non-deep basic property values', ->
      test = a: 0
      util.prop test, 'a', 1
      expect(test).to.have.property('a').that.equals(1)
      util.prop test, 'b', 2
      expect(test).to.have.property('b').that.equals(2)

    it 'should correctly set deep basic property values', ->
      test = a: b: 0
      util.prop test, 'a.b', prop: 'value'
      expect(test).to.have.deep.property('a.b').that.equals(prop: 'value')
      util.prop test, 'a.b.c', 2
      expect(test).to.have.deep.property('a.b.c').that.equals(2)

    it 'should correctly set array items', ->
      test = [0, 1, 2, 3, 4]
      util.prop test, '[2]', 9
      expect(test).to.be.deep.equal([0,1,9,3,4])
