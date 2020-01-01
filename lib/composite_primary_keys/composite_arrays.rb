module CompositePrimaryKeys
  ID_SEP     = ','
  ID_SET_SEP = ';'
  ESCAPE_CHAR = '^'

  module ArrayExtension
    def to_composite_keys
      CompositeKeys.new(self)
    end
  end

  # Convert mixed representation of CPKs (by strings or arrays) to normalized
  # representation (just by arrays).
  #
  # `ids` is Array that may contain:
  # 1. A CPK represented by an array or a string.
  # 2. An array of CPKs represented by arrays or strings.
  #
  # There is an issue. Let `ids` contain an array with serveral strings. We can't distinguish case 1
  # from case 2 there in general. E.g. the item can be an array containing appropriate number of strings,
  # and each string can contain appropriate number of commas. We consider case 2 to win there.
  def self.normalize(ids, cpk_size)
    ids.map do |id|
      if Utils.cpk_as_array?(id, cpk_size) && id.any? { |item| !Utils.cpk_as_string?(item, cpk_size) }
        # CPK as an array - case 1
        id
      elsif id.is_a?(Array)
        # An array of CPKs - case 2
        normalize(id, cpk_size)
      elsif id.is_a?(String)
        # CPK as a string - case 1
        CompositeKeys.parse(id)
      else
        id
      end
    end
  end

  class CompositeKeys < Array

    def self.parse(value)
      case value
      when Array
        value.to_composite_keys
      when String
        value.split(ID_SEP).map { |key| Utils.unescape_string_key(key) }.to_composite_keys
      else
        raise(ArgumentError, "Unsupported type: #{value}")
      end
    end

    def in(other)
      case other
        when Arel::SelectManager
          Arel::Nodes::In.new(self, other.ast)
      end
    end


    def to_s
      # Doing this makes it easier to parse Base#[](attr_name)
      map { |key| Utils.escape_string_key(key.to_s) }.join(ID_SEP)
    end
  end

  module Utils
    class << self
      def escape_string_key(key)
        key.gsub(Regexp.union(ESCAPE_CHAR, ID_SEP)) do |unsafe|
          "#{ESCAPE_CHAR}#{unsafe.ord.to_s(16).upcase}"
        end
      end

      def unescape_string_key(key)
        key.gsub(/#{Regexp.escape(ESCAPE_CHAR)}[0-9a-fA-F]{2}/) do |escaped|
          char = escaped.slice(1, 2).hex.chr
          (char == ESCAPE_CHAR || char == ID_SEP) ? char : escaped
        end
      end

      def cpk_as_array?(value, pk_size)
        # We don't permit Array to be an element of CPK.
        value.is_a?(Array) && value.size == pk_size && value.none? { |item| item.is_a?(Array) }
      end

      def cpk_as_string?(value, pk_size)
        value.is_a?(String) && value.count(ID_SEP) == pk_size - 1
      end
    end
  end
  private_constant :Utils
end

Array.send(:include, CompositePrimaryKeys::ArrayExtension)
