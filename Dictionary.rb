
require "Pointable.rb"

class DictionaryString

    def initialize(s)
        @s = s
    end

    def to_s
        @s
    end

    def write(data)
        @pos = data.pos
        data.putstring(@s)
    end

    include Pointable
end

class Dictionary

    include Pointable
    
    def initialize()
        @strings = {}
    end

    def [](s)
        if @strings[s] == nil then
            @strings[s] = DictionaryString.new(s)
        end

        @strings[s]
    end

    def build
        # build a byte array of all the data

        @data = ByteArrayStream.new

        @strings.each_value do |str|
            str.write(@data)
        end
    end

    def write(stream)
        @pos = stream.pos
        @data.write(stream)
    end
end

