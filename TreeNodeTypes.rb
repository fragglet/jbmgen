
require 'TreeNode.rb'

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

