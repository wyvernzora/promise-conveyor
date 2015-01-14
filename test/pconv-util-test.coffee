should = require('chai').should()
expect = require('chai').expect
pconv = require('../dist/conveyor.js')

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



describe 'pconv.util', ->

  describe '#prop() for getting deep properties', ->

    it 'should correctly get non-deep basic property values', ->
      expect(pconv.util.prop test, 'a').to.be.equal('a')
      expect(pconv.util.prop test, 'b').to.be.equal('b')

    it 'should return undefined for non-deep properties that don\'t exist.', ->
      expect(pconv.util.prop test, 'z').to.be.undefined()

    it 'should correctly get deep basic property values', ->
      expect(pconv.util.prop test, 'c.a').to.be.equal('c.a')
      expect(pconv.util.prop test, 'c.d.a').to.be.equal('c.d.a')

    it 'should return undefined for deep properties that don\'t exist', ->
      expect(pconv.util.prop test, 'z.a.b').to.be.undefined()

    it 'should corretly get properties whose value is an object', ->
      expect(pconv.util.prop test, 'c.d').to.be.deep.equal(a: 'c.d.a', b: 'c.d.b')

    it 'should correctly get properties whose value is an array', ->
      expect(pconv.util.prop test, 'd').to.be.deep.equal(['d.0', 'd.1', 'd.2'])

    it 'should correctly get array items using both index notations', ->
      expect(pconv.util.prop test, 'e[0]').to.be.equal('e.0')
      expect(pconv.util.prop test, 'e.0').to.be.equal('e.0')

    it 'should correctly get properties of objects inside arrays', ->
      expect(pconv.util.prop test, 'e[3].a').to.be.equal('e[3].a')
      expect(pconv.util.prop test, 'e.3.b').to.be.equal('e[3].b')

    it 'should return undefined for array items that don\'t exist', ->
      expect(pconv.util.prop test, 'e[9]').to.be.undefined()

  describe '#prop() for setting deep properties', ->
    
