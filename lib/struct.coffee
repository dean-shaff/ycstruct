class Struct
  endian: 'BE'

  constructor: (@format, @fill = null, @encoding = 'binary') ->
    @fmts = []

    offset = 0

    if format[0] is '>'
      @endian = 'BE'
      format = format[1..]
    else if format[0] is '<'
      @endian = 'LE'
      format = format[1..]

    for fmt in format.match /[0-9]*./g
      if fmt.length > 1
        count = parseInt fmt
        fmt = fmt[fmt.length - 1]
      else
        count = 1
      if fmt is 's' or fmt is '='
        @fmts.push [offset, fmt, count]
        offset += count
        continue
      for i in [0...count]
        switch fmt
          when 'x'
            offset += 1
          when 'b', 'B'
            @fmts.push [offset, fmt, 1]
            offset += 1
          when 'h', 'H'
            @fmts.push [offset, fmt, 2]
            offset += 2
          when 'i', 'I'
            @fmts.push [offset, fmt, 4]
            offset += 4
          when 'f'
            @fmts.push [offset, fmt, 4]
            offset += 4
          when 'd'
            @fmts.push [offset, fmt, 8]
            offset += 8
          else
            throw new Error "bad format charactor '#{fmt}'"
    @size = offset

  pack: (values...) ->
    buff = new Buffer @size

    if @fill isnt null
      buff.fill @fill

    count = values.length
    fmts = @fmts

    if count != fmts.length
      console.log fmts
      throw new Error "need #{fmts.length} values to pack, but got #{count}"

    if @endian is 'BE'
      for i in [0...count]
        [offset, fmt, size] = fmts[i]
        value = values[i]
        switch fmt
          when 'b' then buff.writeInt8      value, offset
          when 'B' then buff.writeUInt8     value, offset
          when 'h' then buff.writeInt16BE   value, offset
          when 'H' then buff.writeUInt16BE  value, offset
          when 'i' then buff.writeInt32BE   value, offset
          when 'I' then buff.writeUInt32BE  value, offset
          when 'f' then buff.writeFloatBE   value, offset
          when 'd' then buff.writeDoubleBE  value, offset
          when 's' then buff.write  value, offset, Math.min(value.length, size), @encoding
          when '=' then value.copy  buff, offset, 0, Math.min(value.length, size)
    else
      for i in [0...count]
        [offset, fmt, size] = fmts[i]
        value = values[i]
        switch fmt
          when 'b' then buff.writeInt8      value, offset
          when 'B' then buff.writeUInt8     value, offset
          when 'h' then buff.writeInt16LE   value, offset
          when 'H' then buff.writeUInt16LE  value, offset
          when 'i' then buff.writeInt32LE   value, offset
          when 'I' then buff.writeUInt32LE  value, offset
          when 'f' then buff.writeFloatLE   value, offset
          when 'd' then buff.writeDoubleLE  value, offset
          when 's' then buff.write  value, offset, Math.min(value.length, size), @encoding
          when '=' then value.copy  buff, offset, 0, Math.min(value.length, size)
    buff

  unpack: (buff) ->
    fmts = @fmts
    results = []
    if @endian is 'BE'
      for [offset, fmt, size] in fmts
        switch fmt
          when 'b' then results.push buff.readInt8      offset
          when 'B' then results.push buff.readUInt8     offset
          when 'h' then results.push buff.readInt16BE   offset
          when 'H' then results.push buff.readUInt16    offset
          when 'i' then results.push buff.readInt32BE   offset
          when 'I' then results.push buff.readUInt32BE  offset
          when 'f' then results.push buff.readFloatBE   offset
          when 'd' then results.push buff.readDoubleBE  offset
          when 's' then results.push buff.toString      @encoding, offset, offset + size
          when '=' then results.push buff.slice         offset, offset + size
    else
      for [offset, fmt, size] in fmts
        switch fmt
          when 'b' then results.push buff.readInt8      offset
          when 'B' then results.push buff.readUInt8     offset
          when 'h' then results.push buff.readInt16LE   offset
          when 'H' then results.push buff.readUInt16    offset
          when 'i' then results.push buff.readInt32LE   offset
          when 'I' then results.push buff.readUInt32LE  offset
          when 'f' then results.push buff.readFloatLE   offset
          when 'd' then results.push buff.readDoubleLE  offset
          when 's' then results.push buff.toString      @encoding, offset, offset + size
          when '=' then results.push buff.slice         offset, offset + size
    results
          
module.exports = Struct
