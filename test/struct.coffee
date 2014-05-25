assert = require 'assert'
Struct = require '../lib/struct'

describe 'Struct', ->
  describe '#()', ->
    it 'endian', ->
      new Struct('x').endian.should.equal 'BE'
      new Struct('>x').endian.should.equal 'BE'
      new Struct('<x').endian.should.equal 'LE'

    it 'single format charactor', ->
      new Struct 'xbBhHiIfds='

    it 'format charactor with size', ->
      new Struct '2b5s5='

  it '#size', ->
    new Struct('x').size.should.equal 1
    new Struct('bB').size.should.equal 2
    new Struct('hH').size.should.equal 4
    new Struct('iI').size.should.equal 8
    new Struct('f').size.should.equal 4
    new Struct('d').size.should.equal 8
    new Struct('4x').size.should.equal 4
    new Struct('4I').size.should.equal 16

  describe '#pack/unpack numbers', ->
    describe 'BE', ->
      it 'signed', ->
        st = new Struct 'bbhhii'
        numbers = [12, -12, 1234, -1234, 12345678, -12345678]
        buff = st.pack numbers...
        assert.deepEqual numbers, st.unpack(buff)

      it 'unsigned', ->
        st = new Struct 'BHI'
        buff = st.pack 0x12, 0x1234, 0x12345678
        assert.deepEqual buff, new Buffer('12123412345678', 'hex')

      it 'multiple unsigned', ->
        st = new Struct '2B2H'
        buff = st.pack 0x12, 0x23, 0x3456, 0x4567
        assert.deepEqual buff, new Buffer('122334564567', 'hex')

    describe 'LE', ->
      it 'signed', ->
        st = new Struct '<bbhhii'
        numbers = [12, -12, 1234, -1234, 12345678, -12345678]
        buff = st.pack numbers...
        assert.deepEqual numbers, st.unpack(buff)

      it 'unsigned', ->
        st = new Struct '<BHI'
        buff = st.pack 0x12, 0x1234, 0x12345678
        assert.deepEqual buff,new Buffer('12341278563412', 'hex')

      it 'multiple unsigned', ->
        st = new Struct '<2B2H'
        buff = st.pack 0x12, 0x23, 0x3456, 0x4567
        assert.deepEqual buff, new Buffer('122356346745', 'hex')

  describe '#pack', ->
    it 'string', ->
      st = new Struct 's2s3s4s', 0x00
      buff = st.pack 'A', 'AB', 'ABCD', 'AB'
      assert.deepEqual buff, new Buffer('41414241424341420000', 'hex')

    it 'string fill', ->
      st = new Struct 's2s3s4s', 0xee
      buff = st.pack 'A', 'AB', 'ABCD', 'AB'
      assert.deepEqual buff, new Buffer('4141424142434142eeee', 'hex')

    it 'string encoding', ->
      st = new Struct 's2s3s4s', 0x00, 'hex'
      buff = st.pack '41', '4142', '41424344', '4142'
      assert.deepEqual buff, new Buffer('41414241424341420000', 'hex')

    it 'buffer', ->
      st = new Struct '=2=3=4=', 0xbb
      buff = st.pack new Buffer('A'), new Buffer('AB'), new Buffer('ABCD'), new Buffer('AB')
      assert.deepEqual buff, new Buffer('4141424142434142bbbb', 'hex')

  describe '#unpack', ->
    it 'string', ->
      st = new Struct 's2s3s4s', 0x00
      buff = new Buffer('41414241424341420000', 'hex')
      assert.deepEqual st.unpack(buff), ['A', 'AB', 'ABC', 'AB\x00\x00']

    it 'string encoding', ->
      st = new Struct 's2s3s4s', 0x00, 'hex'
      buff = new Buffer('41414241424341420000', 'hex')
      assert.deepEqual st.unpack(buff), ['41', '4142', '414243', '41420000']

    it 'buffer', ->
      st = new Struct '=2=3=4=', 0xbb
      buff = new Buffer('4141424142434142bbbb', 'hex')
      expected = [new Buffer('A'), new Buffer('AB'), new Buffer('ABC'), new Buffer('4142bbbb', 'hex')]
      assert.deepEqual st.unpack(buff), expected
