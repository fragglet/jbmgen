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

# similarly to the dictionary, a list of paths is stored, allowing them
# to be reused and the file kept compact as a result. when a file is
# stored, it contains the index of an entry in the path list, giving
# the directory the file is stored in.

# paths are stored as an array of directory names, eg.
# Music/the_smashing_pumpkins/1991_gish 
#   becomes 
# [ "Music", "the_smashing_pumpkins", "1991_gish" ]
#
# the individual strings are then just entries in the dictionary

# a path

class Path

    include Pointable
    
    attr_reader :directories

    def initialize(dict, path)
        dirnames = path.split(/\//)
        @directories = dirnames.collect { |dir| dict[dir] }
    end

    def to_s
        dirnames = @directories.collect { |dir| dir.to_s }
        dirnames.join('/')
    end

    def write(data)
        @pos = data.pos
        data.put32(@directories.length)
        @directories.each do |dir|
            data.putptr dir
        end
    end
end

class PathList
    def initialize(dict)
        @dict = dict
        @paths = {}
    end

    def [](s)
        if @paths[s] == nil then
            @paths[s] = Path.new(@dict, s)
        end

        @paths[s]
    end

    def build
        @data = ByteArrayStream.new

        @paths.each_value do |path|
            path.write(@data)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end

    include Pointable
end


