# jbmgen, a tool for generating the lib.jbm file for the Archos GMini
# Copyright (C) 2004 Simon Howard
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#


# binary mixin with methods to write different sizes of integers

module BinaryStuff

    def put8(i)
        putc(i)
    end

    def put16(i)
        putc(i & 0xff)
        putc((i >> 8) & 0xff)
    end

    def put24(i)
        putc(i & 0xff)
        putc((i >> 8) & 0xff)
        putc((i >> 16) & 0xff)
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

# this behaves like a stream but just saves what you write to it
# into an array

class ByteArrayStream

    include BinaryStuff

    attr_accessor :pos

    def initialize()
        @data = []
        @pos = 0
    end

    def putc(i)
        @data[@pos] = i
        @pos += 1
    end

    def length
        @data.length
    end

    def write(stream)
        @data.each do |b|
            stream.putc b
        end
    end
end


