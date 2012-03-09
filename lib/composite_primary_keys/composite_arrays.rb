module CompositePrimaryKeys
  ID_SEP     = ','
  ID_SET_SEP = ';'

  module ArrayExtension
    def to_composite_keys
      CompositeKeys.new(self)
    end
  end

  class CompositeKeys < Array
    def to_s
      # Doing this makes it easier to parse Base#[](attr_name)
      join(ID_SEP)
    end

    def hash
      to_s.hash
    end

    def ==(other_composite_keys)
      to_s == other_composite_keys.to_s
    end

    alias :eql? :==
  end
end

Array.send(:include, CompositePrimaryKeys::ArrayExtension)
