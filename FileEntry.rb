# jbmgen, a tool for generating the lib.jbm file for the Archos GMini
# Copyright (C) 2004 Simon Howard
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#


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
    attr_reader :genre_s
    attr_reader :track

    def name
        @filename
    end

    def initialize(pathlist, dict, filename)

        path, extension = nil, nil

        if filename =~ /^(.*)\/(.*)\.(.*)/
            path, filename, extension = $1, $2, $3
        elsif filename !~ /\// && filename =~ /^(.*)\.(.*)/
            path, filename, extension = '', $1, $2
        else
            raise "Invalid filename"
        end

        extensions = {
            'mp3' => 0,
            'mp2' => 1,
            'wav' => 2,
            'wma' => 3,
        }

        extension.downcase!
        if extensions[extension] != nil then
            @type = extensions[extension]
        else
            raise "Unknown file extension: '#{extension}'"
        end

        @dict = dict
        @path = pathlist[path]
        @filename = dict[filename]
        
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

    def tag_data(info)
        tag1 = info.tag1 || {}
        tag2 = info.tag2 || {}
        data = {
            'artist' => tag2['TPE1'] || tag2['TP1'] || tag1['artist'],
            'album' => tag2['TALB'] || tag2['TAL'] || tag1['album'],
            'title' => tag2['TIT2'] || tag2['TT2'] || tag1['title'],
            'track' => tag2['TRCK'] || tag2['TRK'] || tag1['tracknum'],
            'year' => tag2['TYER'] || tag2['TYE'] || tag1['year'],
            'genre' => tag1['genre'],
            'genre_s' => tag2['TCON'] || tag2['TCO'] || tag1['genre_s'],
        }
        for key in data.keys
            data.delete(key) if data[key] == ''
        end
        for key in ['year', 'track', 'genre']
            data[key] = data[key].to_i if data[key] != nil
        end

        # in an id3v2 genre string, "(xx)" means id3v1 genre #xx

        if data['genre_s'] != nil && data['genre_s'] =~ /^\((\d+\))$/
            genre_id = $1.to_i
            data['genre_s'] = Mp3Info::GENRES[genre_id]
            data['genre'] = genre_id
        end
        data
    end

    # get the id3 data from the file 
    
    def set_id3info(filename)
        begin
            mp3info = Mp3Info.new(filename)
            data = tag_data(mp3info)
            @artist = @dict[data['artist']] if data['artist']
            @album = @dict[data['album']] if data['album']
            @title = @dict[data['title']] if data['title']
            @track = data['track'] if data['track']
            @year = data['year'] if data['year']
            @genre = data['genre'] if data['genre']
            @genre_s = data['genre_s'] if data['genre_s']
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


