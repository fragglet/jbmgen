require 'BinaryStuff.rb'
require 'Dictionary.rb'
require 'FileEntry.rb'
require 'JBMFile.rb'
require 'Path.rb'
require 'TreeNode.rb'
require 'TreeNodeTypes.rb'

class JBMFile
    def initialize
        @dict = Dictionary.new
        @pathlist = PathList.new(@dict)
        @filelist = FileList.new
        @root_list = RootNode.new(@dict)
        @search_list = @root_list.name_list
    end

    # add in a file, adding to all appropriate lists
    # filename is the actual location of the file;
    # relative_filename is the location in the device (relative
    # to the mountpoint)

    def add_file(filename, relative_filename)
        newfile = FileEntry.new(@pathlist, @dict, relative_filename)
        @filelist.add(newfile)

        # set id3 info
        newfile.set_id3info(filename)

        # add to title list
        @search_list.add(newfile)

        # add to album list 
        album_name = newfile.album
        album_name = "Unknown" if album_name == ""
        album_list = @root_list.album_list.get_path(album_name)
        album_list.add(newfile)

        # add to artist list
        artist_name = newfile.artist
        artist_name = "Unknown" if artist_name == ""
        artist_list = @root_list.artist_list.get_path("#{artist_name}/#{album_name}")
        artist_list.add(newfile)

        # add to genre list
        genre = newfile.genre
        genre_name = if genre == 255
            "Unknown"
        else
            Mp3Info::GENRES[genre]
        end
        genre_list = @root_list.genre_list.get_path(genre_name)
        genre_list.add(newfile)
        
        newfile
    end

    def generate_random_lists
        # dont try and put more items in a list than we have in the
        # entire library !

        track_count = 20
        track_count = @filelist.length if @filelist.length < track_count
    
        # generate 20 playlists

        20.times do |i|
            path = @root_list.random_list.get_path("Random List #{i+1}")
            used_tracks = {}

            # add tracks

            track_count.times do 
                begin
                    file = @filelist[rand(@filelist.length)]
                end until used_tracks[file] == nil
                path.add(file)
                used_tracks[file] = 1
            end
        end
    end

    # we need to give an id to every list in the tree
    # files are already assigned ids as they are added
    # ids for lists are assigned starting with the first id
    # after the end of the files
    #
    # ie. if we have n files, the files have the ids
    #     0..n-1, then n is the id of the first list, n+1
    #     is the id of the second list, etc.

    def assign_ids
        file_id = @filelist.length
        @root_list.traverse_tree do |node|
            node.file_id = file_id 
            file_id += 1
        end
    end

    # count how many lists we have

    def num_lists
        i = 0
        @root_list.traverse_tree do 
            i += 1
        end
        i
    end

    def write_to(filename)
        generate_random_lists

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
        data.put32(@search_list.file_id)

        File.open(filename, 'w') do |file|
            data.write(file)
        end
    end
end


