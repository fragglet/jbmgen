
require "Pointable.rb"

class FileEntry

    include Pointable

    attr_accessor :file_id

    def name
        @filename
    end

    def initialize(pathlist, dict, filename)
        filename =~ /^(.*)\/(.*)\.(.*)/

        path, filename, extension = $1, $2, $3

        extensions = {
            'mp3' => 0,
            'mp2' => 1,
            'wav' => 2,
            'wma' => 3,
        }

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
        @genre = 0
        @year = 0

        # these are always like this:
        @reserved = 0
        @flags = 0
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

class FileList
    include Pointable 

    def initialize
        @files = []
    end

    def add(file)
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


