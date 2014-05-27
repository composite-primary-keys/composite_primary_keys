module ActiveRecord
  module Core
    def init_internals
      pk = self.class.primary_key

      # CPK
      #@attributes[pk] = nil unless @attributes.key?(pk)
      unless self.composite?
        @attributes[pk] = nil unless @attributes.key?(pk)
      end

      @aggregation_cache        = {}
      @association_cache        = {}
      @attributes_cache         = {}
      @readonly                 = false
      @destroyed                = false
      @marked_for_destruction   = false
      @destroyed_by_association = nil
      @new_record               = true
      @txn                      = nil
      @_start_transaction_state = {}
      @transaction_state        = nil
      @reflects_state           = [false]
    end

    def initialize_dup(other) # :nodoc:
      cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
      self.class.initialize_attributes(cloned_attributes, :serialized => false)

      @attributes = cloned_attributes

      # CPK
      #@attributes[self.class.primary_key] = nil
      Array(self.class.primary_key).each {|key| @attributes[key] = nil}

      run_callbacks(:initialize) unless _initialize_callbacks.empty?

      @aggregation_cache = {}
      @association_cache = {}
      @attributes_cache  = {}

      @new_record  = true

      super
    end
  end
end
