require "Pointable.rb"

class ListData
    include Pointable

    def initialize
        data = []
    end

    def add(o)
	data.push(o.id)
    end

    def build
	@data = ByteArrayStream.new
	data.each do |id|
	    @data.puti16(id)
	end
    end
end

class TreeNode

    attr :id

    def initialize(dict)
	children = []
    end

    def add(entry)
	children.push(entry)
    end

    def traverse_tree
	yield
	children.each do |node|
	    if node.respond_to? :traverse_tree
		node.traverse_tree do
		    yield
		end
	    end
	end
    end

    def write(nodedata, listdata)
	
    end
end


