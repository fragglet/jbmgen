
require 'Pointable.rb'
require 'mp3info.rb'

# this is a file stored in the database

class FileEntry

    include Pointable

    attr_accessor :file_id
    attr_reader :title
    attr_reader :album
    attr_reader :artist
    attr_reader :genre
    attr_reader :track

    def name
        @filename
    end

    def initialize(pathlist, dict, filename)
        if filename !~ /^(.*)\/(.*)\.(.*)/
            raise "Invalid filename"
        end

        path, filename, extension = $1, $2, $3

        extensions = {
            'mp3' => 0,
            'mp2' => 1,
            'wav' => 2,
            'wma' => 3,
        }

        @dict = dict
        @path = pathlist[path]
        @filename = dict[filename]

        extension.downcase!
        if extensions[extension] != nil then
            @type = extensions[extension]
        else
            raise "Unknown file extension: '#{extension}'"
        end
        
        # todo: fill these in with id3 data!

        @artist = nil
        @album = nil
        @title = @filename
        @track = 0
        @genre = 255
        @year = 0

        # these are always like this:
        @reserved = 0
        @flags = 0
    end

    def tag_info(info, tag)
        info.tag1[tag] || info.tag2[tag]
    end

    # get the id3 data from the file 
    
    def set_id3info(filename)
        begin
            mp3info = Mp3Info.new(filename)
            artist = @dict[tag_info(mp3info, 'artist')]
            album = @dict[tag_info(mp3info, 'album')]
            title = @dict[tag_info(mp3info, 'title')]
            track = tag_info(mp3info, 'tracknum')
            year = tag_info(mp3info, 'year')
            genre = tag_info(mp3info, 'genre')

            @artist = artist if artist != nil
            @album = album if album != nil
            @title = title if title != nil
            @track = track if track != nil
            @year = year if year != nil
            @genre = genre if genre != nil
        rescue
            # rescue from errors while reading id3
        end
    end

    def write(data)
        @pos = data.pos

        data.putptr @path
        data.putptr @filename
        data.putptr @artist
        data.putptr @album
        data.putptr @title
        data.put8 @flags
        data.put8 @track
        data.put8 @type
        data.put8 @genre
        data.put16 @year
        data.put16 @reserved
    end
end

# the file entries in the .jbm file are stored in a list

class FileList
    include Pointable 

    def initialize
        @files = []
    end

    def [](i)
        @files[i]
    end

    def add(file)
        # assign an id; we take the first available one (at
        # the end of the list), so the id is really the index
        # of the file in the list

        file.file_id = @files.length
        @files.push(file)
    end

    def length
        @files.length
    end

    def build
        @data = ByteArrayStream.new
        @files.each do |file|
            file.write(@data)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end


