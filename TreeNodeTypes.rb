
require 'TreeNode.rb'

# an album

class AlbumNode < TreeNode
    def initialize(*opt)
        super(*opt)
        @type = TreeNode::NODE_ALBUM
    end

    def children
        @children.values.sort { |a, b|
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

# root of the entire hierarchy, holds all the root nodes
# (artist, album, etc)

class RootNode < TreeNode
    attr_reader :name_list
    attr_reader :album_list
    attr_reader :artist_list

    def initialize(dict)
        super(dict, "ROOT", nil)
        @type = TreeNode::NODE_ROOT
        @name_list = NameListNode.new(dict, self)
        @album_list = AlbumListNode.new(dict, self)
        @artist_list = ArtistListNode.new(dict, self)

        add(@name_list)
        add(@album_list)
        add(@artist_list)
    end
end

