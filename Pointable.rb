
# something with a position - this can be relative to the file or relative
# to a section in the file or whatever

module Pointable
    def pos
        if @pos == nil then
            raise "Tried to get the position of #{self.class} #{to_s} before it was known!"
        else
            @pos
        end
    end
end


