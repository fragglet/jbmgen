require 'BinaryStuff.rb'
require 'Dictionary.rb'
require 'FileEntry.rb'
require 'JBMFile.rb'
require 'Path.rb'
require 'TreeNode.rb'

class JBMFile
    def initialize
        @dict = Dictionary.new
        @pathlist = PathList.new(@dict)
        @filelist = FileList.new
        @root_list = TreeNode.new
    end

    def add_file(filename)
        newfile = FileEntry.new(@pathlist, @dict, filename)
        @filelist.add(newfile)
    end

    def assign_ids
        id = @filelist.length
        @root_list.traverse_tree do |node|
            node.id = id 
            id += 1
        end
    end
end


