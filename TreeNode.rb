require "Pointable.rb"

class ListData
    include Pointable

    def initialize
        @entries = []
    end

    def add(o)
        @entries.push(o.id)
    end

    def entries
        @entries.length
    end

    def build
        @data = ByteArrayStream.new
        @entries.each do |id|
            @data.puti16(id)
        end
    end
end

class TreeNode

    attr :id
    attr :type

    def initialize(dict, name, parent)
        @children = []
        @type = 0
        @name = dict[name]
        @parent = parent
    end

    def add(entry)
        @children.push(entry)
    end

    def traverse_tree
        yield
        @children.each do |node|
            if node.respond_to? :traverse_tree
                node.traverse_tree do
                    yield
                end
            end
        end
    end

    def write(nodedata, listdata)
        nodedata.puti8(@type)
        nodedata.puti24(listdata.length)
        nodedata.puti16(@children.length)

        parent_id = 0
        if @parent != nil
            parent_id = @parent.id
        end
        nodedata.puti16(parent_id)
        nodedata.putptr(@name)

        # write list entries

        @children.each do |child|
            listdata.add(child)
        end
    end
end


