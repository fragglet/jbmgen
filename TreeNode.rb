require "Pointable.rb"

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
            puts "file_id: #{file_id}"
            @data.put16(file_id)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end

class TreeNode

    attr_accessor :file_id
    attr_accessor :type
    attr_reader :name

    def initialize(dict, name, parent)
        @children = {}
        @type = 0
        @name = dict[name]
        @parent = parent
    end

    def [](name)
        result = @children[name]
        result
    end

    def add(entry)
        @children[entry.name] = entry
    end

    def traverse_tree
        yield self
        @children.each_value do |node|
            if node.respond_to? :traverse_tree
                node.traverse_tree do |subnode|
                    yield subnode
                end
            end
        end
    end

    def children
        @children.values.sort { |a, b|
            a.name <=> b.name
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


