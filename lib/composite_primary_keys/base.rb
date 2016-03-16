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

      alias_method :primary_key_without_composite_key_support=, :primary_key=
      def primary_key=(keys)
        unless keys.kind_of?(Array)
          self.primary_key_without_composite_key_support = keys
          return
        end

        @primary_keys = keys.map { |k| k.to_s }.to_composite_keys

        class_eval <<-EOV
          extend  CompositeClassMethods
          include CompositeInstanceMethods
        EOV
      end
      alias_method :primary_keys=, :primary_key=

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

      def find_in_batches(options = {})
        return super unless primary_key.is_a?(Array)

        batch_size = options[:batch_size] || 100000
        number_of_rows = count(primary_key.first)
        row_number = 0

        start_pk = order(*primary_key).first.attributes.slice(*primary_key)
        end_id = order(*primary_key).last.attributes.slice(*primary_key)

        while row_number < number_of_rows
          end_row_number = row_number + batch_size - 1
          end_row_number = number_of_rows - 1 if end_row_number > number_of_rows - 1

          # Force the necessary sorting; AR as is will sort a PK table incorrectly
          start_key = order(*primary_key).
                      offset(row_number).
                      first.
                      attributes.
                      slice(*primary_key)

          end_key =   order(*(primary_key.map { |k| "#{k} ASC" })).
                      offset(end_row_number).
                      first.
                      attributes.
                      slice(*primary_key)

          relation = self
          lower_bounds = []
          upper_bounds = []

          # Iterate through the PKs positionally; when we have found a discrepancy between start and end
          # then we know that's where the boundaries are
          primary_key.each do |col|
            if start_key[col] == end_key[col]
              relation = relation.where("`#{col}` = '#{start_key[col]}'")
            else
              lower_bounds << [col, start_key[col]]
              upper_bounds << [col, end_key[col]]
            end
          end

          relation = relation.where(build_batch_case(lower_bounds, '>')) unless lower_bounds.empty?
          relation = relation.where(build_batch_case(upper_bounds, '<')) unless upper_bounds.empty?

          yield(relation)

          row_number = end_row_number + 1
        end
      end

      private

      def build_batch_case(bounds, operator)
        bounds = bounds.dup
        bound = bounds.shift
        if bounds.empty?
          "#{bound[0]} #{operator}= '#{bound[1]}' "
        else
          sql_case = "CASE WHEN #{bound[0]} = '#{bound[1]}' THEN "
          sql_case += build_batch_case(bounds, operator)
          sql_case += "ELSE #{bound[0]} #{operator} '#{bound[1]}' END "
          sql_case
        end
      end
    end

    def composite?
      self.class.composite?
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
        ids = CompositePrimaryKeys::CompositeKeys.parse(ids)
        unless ids.length == self.class.primary_keys.length
          raise "#{self.class}.id= requires #{self.class.primary_keys.length} ids"
        end
        [self.class.primary_keys, ids].transpose.each {|key, an_id| write_attribute(key , an_id)}
        id
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