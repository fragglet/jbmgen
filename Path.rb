require "Pointable.rb"

class Path

    include Pointable
    
    attr_reader :directories

    def initialize(dict, path)
        dirnames = path.split(/\//)
        @directories = dirnames.collect { |dir| dict[dir] }
    end

    def to_s
        dirnames = @directories.collect { |dir| dir.to_s }
        dirnames.join('/')
    end

    def write(data)
        @pos = data.pos
        data.put32(@directories.length)
        @directories.each do |dir|
            data.putptr dir
        end
    end
end

class PathList
    def initialize(dict)
        @dict = dict
        @paths = {}
    end

    def [](s)
        if @paths[s] == nil then
            @paths[s] = Path.new(@dict, s)
        end

        @paths[s]
    end

    def build
        @data = ByteArrayStream.new

        @paths.each_value do |path|
            path.write(@data)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end


