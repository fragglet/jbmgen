
require "Pointable.rb"

# .jbm files have a dictionary for strings; this is used for practically
# everything: filenames, node names, artist and album names, etc.
# this allows the file to be compact as common strings are reused, and
# only a dictionary reference is needed instead of the entire string

# an entry in the dictionary. this is just a normal string
# that knows its position in the file

class DictionaryString < String

    attr_reader :pos

    def initialize(s)
        replace(s)
    end

    def write(data)
        @pos = data.pos
        data.putstring(self)
    end

    include Pointable
end

# dictionary

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


