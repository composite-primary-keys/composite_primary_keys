module ActiveRecord
  class CompositeKeyError < StandardError #:nodoc:
  end

  class Base
    INVALID_FOR_COMPOSITE_KEYS = 'Not appropriate for composite primary keys'
    NOT_IMPLEMENTED_YET        = 'Not implemented for composite primary keys yet'

    class << self
      def set_primary_keys(*keys)
        keys = keys.first if keys.first.is_a?(Array)

        if keys.length == 1
          set_primary_key(keys.first)
          return
        end

        cattr_accessor :primary_keys
        self.primary_keys = keys.map { |k| k.to_sym }

        class_eval <<-EOV
          extend CompositeClassMethods
          include CompositeInstanceMethods
          extend CompositePrimaryKeys::ActiveRecord::NamedScope::ClassMethods
          include CompositePrimaryKeys::ActiveRecord::AssociationPreload
        EOV
      end

      def composite?
        false
      end
    end

    def composite?
      self.class.composite?
    end

    def [](attr_name)
      # CPK
      if attr_name.is_a?(String) and attr_name != attr_name.split(CompositePrimaryKeys::ID_SEP).first
        attr_name = attr_name.split(CompositePrimaryKeys::ID_SEP)
      end

      # CPK
      if attr_name.is_a?(Array)
        values = attr_name.map {|name| read_attribute(name)}
        CompositePrimaryKeys::CompositeKeys.new(values)
      else
        read_attribute(attr_name)
      end
    end

    def []=(attr_name, value)
      # CPK
      if attr_name.is_a?(String) and attr_name != attr_name.split(CompositePrimaryKeys::ID_SEP).first
        attr_name = attr_name.split(CompositePrimaryKeys::ID_SEP)
      end

      if attr_name.is_a? Array
        unless value.length == attr_name.length
          raise "Number of attr_names and values do not match"
        end
        [attr_name, value].transpose.map {|name,val| write_attribute(name, val)}
        value
      else
         write_attribute(attr_name, value)
      end
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

      def quoted_id #:nodoc:
        [self.class.primary_keys, ids].
          transpose.
          map {|attr_name,id| quote_value(id, column_for_attribute(attr_name))}
      end

      # Sets the primary ID.
      def id=(ids)
        ids = ids.split(CompositePrimaryKeys::ID_SEP) if ids.is_a?(String)
        ids.flatten!
        unless ids.is_a?(Array) and ids.length == self.class.primary_keys.length
          raise "#{self.class}.id= requires #{self.class.primary_keys.length} ids"
        end
        [primary_keys, ids].transpose.each {|key, an_id| write_attribute(key , an_id)}
        id
      end

      def ==(comparison_object)
        ids.is_a?(Array) ? super(comparison_object) && ids.all? {|id| id.present?} : super(comparison_object)
      end

      def initialize_dup(other)
        cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
        # CPK
        #cloned_attributes.delete(self.class.primary_key)
        self.class.primary_key.each {|key| cloned_attributes.delete(key.to_s)}

        @attributes = cloned_attributes

        _run_after_initialize_callbacks if respond_to?(:_run_after_initialize_callbacks)

        @changed_attributes = {}
        attributes_from_column_definition.each do |attr, orig_value|
          @changed_attributes[attr] = orig_value if field_changed?(attr, orig_value, @attributes[attr])
        end

        @aggregation_cache = {}
        @association_cache = {}
        @attributes_cache = {}
        @new_record  = true

        ensure_proper_type
        populate_with_current_scope_attributes
        clear_timestamp_attributes
      end
    end
  end
end
