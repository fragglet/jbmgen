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


require 'TreeNode.rb'

# "browse by name"

class NameListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "Name", parent)
        @type = TreeNode::NODE_SONG
    end
end

# "browse by genre"

class GenreNode < TreeNode
    def initialize(*opts)
        super(*opts)
        @type = TreeNode::NODE_GENRE
    end
end

# an album

class AlbumNode < TreeNode
    def initialize(*opt)
        super(*opt)
        @type = TreeNode::NODE_ALBUM
    end

    def children
        super { |a, b|
            a.track <=> b.track
        }
    end

    def new_child(*o)
        puts "#{@name} not supposed to have subdirs"
    end
end

# "browse by album"

class AlbumListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "Album", parent)
        @type = TreeNode::NODE_ALBUM
    end

    def new_child(name)
        super(name, AlbumNode)
    end
end

class AllTracksListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "All Tracks", parent)
        @type = TreeNode::NODE_SONG
    end

    def new_child
        puts "#{@name} not supposed to have subdirs"
    end
end

# "browse by artist"

class ArtistNode < TreeNode
    def initialize(*opts)
        super(*opts)
        @type = TreeNode::NODE_ARTIST
    end

    def new_child(name)
        # then sort by album
        super(name, AlbumNode)
    end

    def generate_all_tracks_list
        if @children.size > 1
            list = AllTracksListNode.new(@dict, self)
            @children.each do |album|
                album.children.each do |song|
                    list.add(song)
                end
            end
            add(list)
        end
    end
end

class ArtistListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "Artist", parent)
        @type = TreeNode::NODE_ARTIST
    end

    def new_child(name)
        super(name, ArtistNode)
    end
end

class GenreListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "Genre", parent)
        @type = TreeNode::NODE_GENRE
    end

    def new_child(name)
        super(name, GenreNode)
    end
end

# lists of random tracks

class RandomNode < TreeNode
    attr_accessor :entry

    def initialize(*opts)
        super(*opts)
        @type = TreeNode::NODE_M3U
    end

    def children
        # dont sort child nodes
        @children
    end
end

class RandomListNode < TreeNode
    def initialize(dict, parent)
        super(dict, "Random", parent)
        @type = TreeNode::NODE_M3U
    end

    def new_child(name)
        node = super(name, RandomNode)
    end

    def children
        # dont sort child nodes
        @children
    end
end

# root of the entire hierarchy, holds all the root nodes
# (artist, album, etc)

class RootNode < TreeNode
    attr_reader :name_list
    attr_reader :album_list
    attr_reader :artist_list
    attr_reader :genre_list
    attr_reader :random_list

    def initialize(dict)
        super(dict, "ROOT", nil)
        @type = TreeNode::NODE_ROOT
        @name_list = NameListNode.new(dict, self)
        @album_list = AlbumListNode.new(dict, self)
        @artist_list = ArtistListNode.new(dict, self)
        @genre_list = GenreListNode.new(dict, self)
        @random_list = RandomListNode.new(dict, self)

        add(@name_list)
        add(@album_list)
        add(@artist_list)
        add(@genre_list)
        add(@random_list)
    end
end

