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


require "Pointable.rb"

# .jbm files have a dictionary for strings; this is used for practically
# everything: filenames, node names, artist and album names, etc.
# this allows the file to be compact as common strings are reused, and
# only a dictionary reference is needed instead of the entire string

# an entry in the dictionary. this is just a normal string
# that knows its position in the file

class DictionaryString < String

    attr_reader :pos

    def initialize(s)
        replace(s)
    end

    def write(data)
        @pos = data.pos
        data.putstring(self)
    end

    include Pointable
end

# dictionary

class Dictionary

    include Pointable
    
    def initialize()
        @strings = {}
    end

    def [](s)
        if @strings[s] == nil then
            @strings[s] = DictionaryString.new(s)
        end

        @strings[s]
    end

    def build
        # build a byte array of all the data

        @data = ByteArrayStream.new

        @strings.each_value do |str|
            str.write(@data)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end


