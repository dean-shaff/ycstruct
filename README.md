ycstruct
========

Just like Python's struct module, pack/unpack values to/from buffer.

Format String
-------------

First charactor can be endian charactor, it can also be omited(default is Big Endian).

    >    Big Endian  
    <    Little Endian

The following charactor can be:

    b    signed int8
    B    unsigned int8
    h    signed int16
    H    unsigned int16
    i    signed int32
    I    unsigned int32
    f    float
    d    double
    s    string (utf8)
    R    buffer

Format charactor can has a number prefix:

- for string and buffer, it's the length of value
- for other format charactor, it's the count of value

When pack/unpack string, only "utf8" encoding is supported, if you want to use other
encoding, try to convert them to Buffer.

- before pack: s = new Buffer(s, 'binary')
- after unpack: s = s.toString('binary')

API
---

  Struct(format, fill = 0x00)
    pack(...)
    unpack(buff)

Usage
-----

    Struct = require('ycstruct')

    # pack numbers
    st = new Struct('>BHI')
    buff = st.pack(12, 1234, 123456)

    results = st.unpack(buff)
    results[0] == 12
    results[1] == 1234
    results[2] == 123456

    # number prefix
    st = new Struct('>3H')
    st.pack(1234, 1234, 1234)

    # pack string
    st = new Struct('12s5s', 0x00)
    buff = st.pack('hello', 'world')

ChangeLog
---------

0.1.0

- remove encoding argument from Struct#constructor, only "utf8" string is supported
- buffer format char changed from "=" to "R"
- allow space in format string, and space is ignore

0.0.1

- initialize version