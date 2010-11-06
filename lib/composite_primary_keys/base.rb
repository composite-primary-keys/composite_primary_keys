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
          include CompositePrimaryKeys::ActiveRecord::AssociationPreload
        EOV

        class << unscoped
          include CompositePrimaryKeys::ActiveRecord::FinderMethods::InstanceMethods
          include CompositePrimaryKeys::ActiveRecord::Relation::InstanceMethods
        end
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
        Array.new(attr_names.map { |attr_name| read_attribute(attr_name) })
      end
      alias_method :ids, :id

      def ids_hash
        self.class.primary_key.zip(ids).inject(Hash.new) do |hash, (key, value)|
          hash[key] = value
          hash
        end
      end

      def to_param
        id.join(CompositePrimaryKeys::ID_SEP)
      end

      def id_before_type_cast #:nodoc:
        raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::NOT_IMPLEMENTED_YET
      end

      def quoted_id #:nodoc:
        [self.class.primary_keys, ids].
          transpose.
          map {|attr_name,id| quote_value(id, column_for_attribute(attr_name))}.
          to_composite_ids
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

      # Cloned objects have no id assigned and are treated as new records. Note that this is a "shallow" clone
      # as it copies the object's attributes only, not its associations. The extent of a "deep" clone is
      # application specific and is therefore left to the application to implement according to its need.
      def initialize_copy(other)
        # Think the assertion which fails if the after_initialize callback goes at the end of the method is wrong. The
        # deleted clone method called new which therefore called the after_initialize callback. It then went on to copy
        # over the attributes. But if it's copying the attributes afterwards then it hasn't finished initializing right?
        # For example in the test suite the topic model's after_initialize method sets the author_email_address to
        # test@test.com. I would have thought this would mean that all cloned models would have an author email address
        # of test@test.com. However the test_clone test method seems to test that this is not the case. As a result the
        # after_initialize callback has to be run *before* the copying of the atrributes rather than afterwards in order
        # for all tests to pass. This makes no sense to me.
        callback(:after_initialize) if respond_to_without_attributes?(:after_initialize)
        cloned_attributes = other.clone_attributes(:read_attribute_before_type_cast)
        # CPK
        #cloned_attributes.delete(self.class.primary_key)
        self.class.primary_key.each {|key| cloned_attributes.delete(key.to_s)}

        @attributes = cloned_attributes
        clear_aggregation_cache
        @attributes_cache = {}
        @new_record = true
        ensure_proper_type

        if scope = self.class.send(:current_scoped_methods)
          create_with = scope.scope_for_create
          create_with.each { |att,value| self.send("#{att}=", value) } if create_with
        end
      end

      def destroy
        if persisted?
          # CPK
          # self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).delete_all
          self.class.unscoped.where(ids_hash).delete_all
        end

        @destroyed = true
        freeze
      end

      def update(attribute_names = @attributes.keys)
        attributes_with_values = arel_attributes_values(false, false, attribute_names)
        return 0 if attributes_with_values.empty?
        # CPK
        # self.class.unscoped.where(self.class.arel_table[self.class.primary_key].eq(id)).arel.update(attributes_with_values)
        self.class.unscoped.where(ids_hash).arel.update(attributes_with_values)
      end
    end
  end
end