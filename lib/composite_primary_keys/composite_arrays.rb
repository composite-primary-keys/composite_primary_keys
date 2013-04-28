module CompositePrimaryKeys
  ID_SEP     = ','
  ID_SET_SEP = ';'

  module ArrayExtension
    def to_composite_keys
      CompositeKeys.new(self)
    end
  end

  class CompositeKeys < Array
    def self.parse(value)
      case value
      when Array
        value.to_composite_keys
      when String
        self.new(value.split(ID_SEP))
      else
        raise(ArgumentError, "Unsupported type: #{value}")
      end
    end

    def to_s
      # Doing this makes it easier to parse Base#[](attr_name)
      join(ID_SEP)
    end
  end
end

Array.send(:include, CompositePrimaryKeys::ArrayExtension)
