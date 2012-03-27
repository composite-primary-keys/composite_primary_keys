module ActiveRecord
  class CompositeKeyError < StandardError #:nodoc:
  end

  class Base
    INVALID_FOR_COMPOSITE_KEYS = 'Not appropriate for composite primary keys'
    NOT_IMPLEMENTED_YET        = 'Not implemented for composite primary keys yet'

    class << self
      def primary_keys
        unless defined?(@primary_keys)
          reset_primary_keys
        end
        @primary_keys
      end

      # Don't like this method name, but its modeled after how AR does it
      def reset_primary_keys
        if self != base_class
          self.primary_keys = base_class.primary_keys
        end
      end

      def primary_keys=(keys)
        unless keys.kind_of?(Array)
          self.primary_key = keys
          return
        end

        @primary_keys = keys.map { |k| k.to_sym }.to_composite_keys

        class_eval <<-EOV
          extend  CompositeClassMethods
          include CompositeInstanceMethods
        EOV
      end

      def set_primary_keys(*keys)
        ActiveSupport::Deprecation.warn(
            "Calling set_primary_keys is deprecated. Please use `self.primary_keys = keys` instead."
        )

        keys = keys.first if keys.first.is_a?(Array)
        if keys.length == 1
          self.primary_key = keys.first
        else
          self.primary_keys = keys
        end
     end

      def composite?
        false
      end
    end

    def composite?
      self.class.composite?
    end

    def initialize_dup(other)
      cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
      # CPK
      # cloned_attributes.delete(self.class.primary_key)
      Array(self.class.primary_key).each {|key| cloned_attributes.delete(key.to_s)}

      @attributes = cloned_attributes

      _run_after_initialize_callbacks if respond_to?(:_run_after_initialize_callbacks)

      @changed_attributes = {}
      self.class.column_defaults.each do |attr, orig_value|
        @changed_attributes[attr] = orig_value if field_changed?(attr, orig_value, @attributes[attr])
      end

      @aggregation_cache = {}
      @association_cache = {}
      @attributes_cache = {}
      @new_record  = true

      ensure_proper_type
      populate_with_current_scope_attributes
      super
    end

    module CompositeClassMethods
      def primary_key
        primary_keys
      end

      def primary_key=(keys)
        primary_keys = keys
      end

      def composite?
        true
      end

      #ids_to_s([[1,2],[7,3]]) -> "(1,2),(7,3)"
      #ids_to_s([[1,2],[7,3]], ',', ';') -> "1,2;7,3"
      def ids_to_s(many_ids, id_sep = CompositePrimaryKeys::ID_SEP, list_sep = ',', left_bracket = '(', right_bracket = ')')
        many_ids.map {|ids| "#{left_bracket}#{CompositePrimaryKeys::CompositeKeys.new(ids)}#{right_bracket}"}.join(list_sep)
      end
    end

    module CompositeInstanceMethods
      # A model instance's primary keys is always available as model.ids
      # whether you name it the default 'id' or set it to something else.
      def id
        attr_names = self.class.primary_keys
        ::CompositePrimaryKeys::CompositeKeys.new(attr_names.map { |attr_name| read_attribute(attr_name) })
      end
      alias_method :ids, :id

      def ids_hash
        self.class.primary_key.zip(ids).inject(Hash.new) do |hash, (key, value)|
          hash[key] = value
          hash
        end
      end

      def id_before_type_cast
        self.class.primary_keys.map do |key|
          self.send("#{key.to_s}_before_type_cast")
        end
      end

      # Sets the primary ID.
      def id=(ids)
        ids = ids.split(CompositePrimaryKeys::ID_SEP) if ids.is_a?(String)
        ids.flatten!
        unless ids.is_a?(Array) and ids.length == self.class.primary_keys.length
          raise "#{self.class}.id= requires #{self.class.primary_keys.length} ids"
        end
        [self.class.primary_keys, ids].transpose.each {|key, an_id| write_attribute(key , an_id)}
        id
      end

      def ==(comparison_object)
        ids.is_a?(Array) ? super(comparison_object) && ids.all? {|id| id.present?} : super(comparison_object)
      end

      def can_change_primary_key_values?
        false
      end

      # Returns this record's primary keys values in an Array
      # if any value is available
      def to_key
        ids.to_a if !ids.compact.empty? # XXX Maybe use primary_keys with send instead of ids
      end
      
      def to_param
        persisted? ? to_key.join(CompositePrimaryKeys::ID_SEP) : nil
      end
    end
  end
end
