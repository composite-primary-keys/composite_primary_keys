module ActiveModel
  module Dirty
    def can_change_primary_key?
      true
    end

    def primary_key_changed?
      !!changed.detect { |key| ids_hash.keys.include?(key.to_sym) }
    end

    def primary_key_was
      ids_hash.keys.inject(Hash.new) do |result, attribute_name|
        result[attribute_name.to_sym] = attribute_was(attribute_name.to_s)
        result
      end
    end
    alias_method :ids_hash_was, :primary_key_was
  end
end
