#!/usr/bin/env ruby

module BinaryStuff

    def put8(i)
        putc(i)
    end

    def put16(i)
        putc(i & 0xff)
        putc((i >> 8) & 0xff)
    end

    def put32(i)
        putc(i & 0xff)
        putc((i >> 8) & 0xff)
        putc((i >> 16) & 0xff)
        putc((i >> 24) & 0xff)
    end

    def putstring(s)
        s.each_byte do |c|
            putc(c)
        end
        putc(0)
    end

    def putptr(o)
        val = 0xffffffff
        if o != nil then
            val = o.pos
        end
        put32(val)
    end

    # pad out to the next 512-byte boundary
    def pad
        while (pos % 512 != 0)
            putc(0)
        end
    end
end

class IO
    include BinaryStuff
end

class ByteArrayStream

    include BinaryStuff

    attr :pos

    def initialize()
        @data = []
        @pos = 0
    end

    def putc(i)
        @data[@pos] = i
        @pos += 1
    end

    def write(stream)
        @data.each do |b|
            stream.putc b
        end
    end
end


