# frozen_string_literal: true

module ActiveRecord::Associations
  module ForeignAssociation # :nodoc:
    def foreign_key_present?
      if reflection.klass.primary_key
        # CPK
        # owner.attribute_present?(reflection.active_record_primary_key)
        Array(reflection.active_record_primary_key).all? {|key| owner.attribute_present?(key)}
      else
        false
      end
    end
  end
end
