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
        @root_list = TreeNode.new(@dict, "ROOT", nil)
        path = get_path("Name")
        @search_list = path
    end

    def get_path(path)
        dir, filename = nil, nil

        if path =~ /^(.*)\/(.*?)$/
            dirname, filename = $1, $2
            dir = get_path(dirname)
        else
            dir = @root_list
            filename = path
        end

        if dir[filename] == nil 
            newnode = TreeNode.new(@dict, filename, dir)
            dir.add(newnode)
        end
        
        dir[filename]
    end

    def add_file(filename, relative_filename)
        newfile = FileEntry.new(@pathlist, @dict, relative_filename)
        @filelist.add(newfile)

        # set id3 info
        newfile.set_id3info(filename)
        @search_list.add(newfile)
        
        newfile
    end

    def assign_ids
        file_id = @filelist.length
        @root_list.traverse_tree do |node|
            node.file_id = file_id 
            file_id += 1
        end
    end

    def num_lists
        i = 0
        @root_list.traverse_tree do 
            i += 1
        end
        i
    end

    def write_to(filename)
        @dict.build
        @pathlist.build
        @filelist.build
        assign_ids

        data = ByteArrayStream.new
        listdata = ListData.new

        # pad the start, we'll come back later..
        
        data.put8(0)
        data.pad
        
        @filelist.write(data)
        data.pad
        @pathlist.write(data)
        data.pad
        listptr = data.pos
        @root_list.traverse_tree do |list|
            list.write(data, listdata)
        end
        data.pad
        listdata.build
        listdata.write(data)
        data.pad
        @dict.write(data)
        data.pad

        # go back and write the header

        data.pos = 0
        "JBML".each_byte { |b| data.put8(b) }
        data.put32(0x0102)
        data.put32(@filelist.length)
        data.put32(num_lists)
        data.putptr(@filelist)
        data.put32(listptr)
        data.putptr(listdata)
        data.putptr(@pathlist)
        data.putptr(@dict)
        data.put32(data.length)
        data.put32(@search_list.file_id)     # this should be the search list

        File.open(filename, 'w') do |file|
            data.write(file)
        end
    end
end


