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

# lists store the file ids of the data contained inside them
# all these lists of ids are then put into a single long array.
# the list has the index of the point in this array where its list
# data starts.

class ListData
    include Pointable

    def initialize
        @entries = []
    end

    def add(o)
        @entries.push(o.file_id)
    end

    def length
        @entries.length
    end

    def build
        @data = ByteArrayStream.new
        @entries.each do |file_id|
            @data.put16(file_id)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end

# a list in the browsing tree - contains either more lists
# or some references to files

class TreeNode

    NODE_ROOT=0
    NODE_ARTIST=1
    NODE_ALBUM=2
    NODE_SONG=3
    NODE_M3U=4
    NODE_GENRE=5
    NODE_YEAR=6

    attr_accessor :file_id
    attr_accessor :type
    attr_reader :name

    def initialize(dict, name, parent)
        @children = []
        @children_hash = {}
        @type = 0
        @dict = dict
        @name = dict[name]
        @parent = parent
    end

    def [](name)
        result = @children_hash[name]
        result
    end

    def add(entry)
        @children_hash[entry.name] = entry
        @children.push(entry)
    end

    # add a new "directory"

    def new_child(name, nodetype=TreeNode)
        child = nodetype.new(@dict, name, self)
        add(child)
        child
    end

    # perform an action on all sublists

    def traverse_tree
        yield self
        children.each do |node|
            if node.respond_to? :traverse_tree
                node.traverse_tree do |subnode|
                    yield subnode
                end
            end
        end
    end

    # search down to find a path; recursive

    def get_path(path_list)
    
        dir, path = path_list[0], path_list[1..-1]

        if @children_hash[dir] == nil 
            new_child(dir)
        end

        if path.length == 0
            @children_hash[dir]
        else
            @children_hash[dir].get_path(path)
        end
    end

    def children
        @children.sort { |a, b|
            if block_given?
                yield a, b
            elsif a.respond_to? :title
                a.title.downcase <=> b.title.downcase
            else
                a.name.downcase <=> b.name.downcase
            end
        }
    end

    def write(nodedata, listdata)
        nodedata.put8(@type)
        nodedata.put24(listdata.length)
        nodedata.put16(@children.length)

        parent_id = 0
        if @parent != nil
            parent_id = @parent.file_id
        end
        nodedata.put16(parent_id)
        nodedata.putptr(@name)

        # write list entries

        children.each do |child|
            listdata.add(child)
        end
    end
end


