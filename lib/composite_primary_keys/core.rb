module ActiveRecord
  module Core
    def init_internals_with_cpk
      init_internals_without_cpk
      # Remove cpk array from attributes, fixes to_json
      @attributes.delete(self.class.primary_key) if self.composite?
    end
    alias_method_chain :init_internals, :cpk

    def initialize_dup(other)
      cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
      self.class.initialize_attributes(cloned_attributes, :serialized => false)
      # CPK
      # cloned_attributes.delete(self.class.primary_key)
      Array(self.class.primary_key).each {|key| cloned_attributes.delete(key.to_s)}
      @attributes = cloned_attributes
      
      run_callbacks(:initialize) unless _initialize_callbacks.empty?

      @changed_attributes = {}
      self.class.column_defaults.each do |attr, orig_value|
        @changed_attributes[attr] = orig_value if _field_changed?(attr, orig_value, @attributes[attr])
      end

      @aggregation_cache = {}
      @association_cache = {}
      @attributes_cache  = {}

      @new_record  = true

      ensure_proper_type
      super
    end
  end
end
