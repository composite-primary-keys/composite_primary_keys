module CompositePrimaryKeys
  module ActiveRecord #:nodoc:
    class CompositeKeyError < StandardError #:nodoc:
    end

    module Base #:nodoc:

      INVALID_FOR_COMPOSITE_KEYS = 'Not appropriate for composite primary keys'
      NOT_IMPLEMENTED_YET = 'Not implemented for composite primary keys yet'
       
      def self.append_features(base)
        super
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def set_primary_keys(*keys)
          keys = keys.first if keys.first.is_a?(Array)
          cattr_accessor :primary_keys 
          self.primary_keys = keys.to_composite_keys
          
          class_eval <<-EOV
            extend CompositePrimaryKeys::ActiveRecord::Base::CompositeClassMethods
            include CompositePrimaryKeys::ActiveRecord::Base::CompositeInstanceMethods
            include CompositePrimaryKeys::ActiveRecord::Associations
          EOV
        end
        
        def composite?
          false
        end
      end
      
      module InstanceMethods
        def composite?; self.class.composite?; end
      end
     
      module CompositeInstanceMethods  
        
        # A model instance's primary keys is always available as model.ids
        # whether you name it the default 'id' or set it to something else.
        def id
          attr_names = self.class.primary_keys
          CompositeIds.new(
            attr_names.map {|attr_name| read_attribute(attr_name)}
          )
        end
        alias_method :ids, :id
        
        def to_param
          id.to_s
        end
        
        def id_before_type_cast #:nodoc:
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::NOT_IMPLEMENTED_YET
        end
  
        def quoted_id #:nodoc:
          [self.class.primary_keys, ids].
            transpose.
            map {|attr_name,id| quote(id, column_for_attribute(attr_name))}.
            to_composite_ids
        end
  
        # Sets the primary ID.
        def id=(ids)
          ids = ids.split(ID_SEP) if ids.is_a?(String)
          ids.flatten!
          unless ids.is_a?(Array) and ids.length == self.class.primary_keys.length
            raise "#{self.class}.id= requires #{self.class.primary_keys.length} ids"
          end
          [primary_keys, ids].transpose.each {|key, an_id| write_attribute(key , an_id)}
          id
        end
          
        # Returns a clone of the record that hasn't been assigned an id yet and
        # is treated as a new record.  Note that this is a "shallow" clone:
        # it copies the object's attributes only, not its associations.
        # The extent of a "deep" clone is application-specific and is therefore
        # left to the application to implement according to its need.
        def clone
          attrs = self.attributes_before_type_cast
          self.class.primary_keys.each {|key| attrs.delete(key.to_s)}
          self.class.new do |record|
            record.send :instance_variable_set, '@attributes', attrs
          end
        end
  
        # Define an attribute reader method.  Cope with nil column.
        def define_read_method(symbol, attr_name, column)
          cast_code = column.type_cast_code('v') if column
          access_code = cast_code ? "(v=@attributes['#{attr_name}']) && #{cast_code}" : "@attributes['#{attr_name}']"
          
          unless self.class.primary_keys.include? attr_name.to_sym
            access_code = access_code.insert(0, "raise NoMethodError, 'missing attribute: #{attr_name}', caller unless @attributes.has_key?('#{attr_name}'); ")
            self.class.read_methods << attr_name
          end
          
          evaluate_read_method attr_name, "def #{symbol}; #{access_code}; end"
        end
        
        def method_missing(method_id, *args, &block)
          method_name = method_id.to_s
          if @attributes.include?(method_name) or
              (md = /\?$/.match(method_name) and
              @attributes.include?(method_name = md.pre_match))
            define_read_methods if self.class.read_methods.empty? && self.class.generate_read_methods
            md ? query_attribute(method_name) : read_attribute(method_name)
          elsif self.class.primary_keys.include? method_name.to_sym
            get_attr(method_name.to_sym)
          elsif md = /(=|_before_type_cast)$/.match(method_name)
            attribute_name, method_type = md.pre_match, md.to_s
            if @attributes.include?(attribute_name)
              case method_type
                when '='
                  write_attribute(attribute_name, args.first)
                when '_before_type_cast'
                  read_attribute_before_type_cast(attribute_name)
              end
            else
              super
            end
          else
            super
          end
        end
        
      private
        # The xx_without_callbacks methods are overwritten as that is the end of the alias chain
      
        # Creates a new record with values matching those of the instance attributes.
        def create_without_callbacks
          unless self.id
            raise CompositeKeyError, "Composite keys do not generated ids from sequences, you must provide id values"
          end
  
          self.id = connection.insert(
            "INSERT INTO #{self.class.table_name} " +
            "(#{quoted_column_names.join(', ')}) " +
            "VALUES(#{attributes_with_quotes.values.join(', ')})",
            "#{self.class.name} Create",
            self.class.primary_key, self.id
          )
          @new_record = false
          return true
        end
        
        # Updates the associated record with values matching those of the instance attributes.
        def update_without_callbacks
          connection.update(
            "UPDATE #{self.class.table_name} " +
            "SET #{quoted_comma_pair_list(connection, attributes_with_quotes(false))} " +
            "WHERE (#{self.class.primary_key}) = (#{id})",
            "#{self.class.name} Update"
          )
          return true
        end
        
        # Deletes the record in the database and freezes this instance to reflect that no changes should
        # be made (since they can't be persisted).
        def destroy_without_callbacks
          unless new_record?
            connection.delete <<-end_sql, "#{self.class.name} Destroy"
              DELETE FROM #{self.class.table_name}
              WHERE (#{self.class.primary_key}) = (#{quoted_id})
            end_sql
          end
  
          freeze
        end
  
      end
      
      module CompositeClassMethods
        def primary_key; primary_keys; end
        def primary_key=(keys); primary_keys = keys; end
        
        def composite?
          true
        end
       
        #ids_to_s([[1,2],[7,3]]) -> "(1,2),(7,3)"
        #ids_to_s([[1,2],[7,3]], ',', ';') -> "1,2;7,3"
        def ids_to_s(many_ids, id_sep = CompositePrimaryKeys::ID_SEP, list_sep = ',', left_bracket = '(', right_bracket = ')')
          many_ids.map {|ids| "#{left_bracket}#{ids}#{right_bracket}"}.join(list_sep)
        end
  
        # Returns true if the given +ids+ represents the primary keys of a record in the database, false otherwise.
        # Example:
        #   Person.exists?(5,7)
        def exists?(ids)
          obj = find(ids) rescue false
          !obj.nil? and obj.is_a?(self)
        end
  
        # Deletes the record with the given +ids+ without instantiating an object first, e.g. delete(1,2)
        # If an array of ids is provided (e.g. delete([1,2], [3,4]), all of them
        # are deleted.
        def delete(*ids)
          unless ids.is_a?(Array); raise "*ids must be an Array"; end
          ids = [ids.to_composite_ids] if not ids.first.is_a?(Array)
          delete_all([ "(#{primary_keys}) IN (#{ids_to_s(ids)})" ])
        end
  
        # Destroys the record with the given +ids+ by instantiating the object and calling #destroy (all the callbacks are the triggered).
        # If an array of ids is provided, all of them are destroyed.
        def destroy(*ids)
          unless ids.is_a?(Array); raise "*ids must be an Array"; end
          if ids.first.is_a?(Array)
            ids = ids.map{|compids| compids.to_composite_ids}
          else
            ids = ids.to_composite_ids
          end
          ids.first.is_a?(CompositeIds) ? ids.each { |id_set| find(id_set).destroy } : find(ids).destroy
        end
       
        # Returns an array of column objects for the table associated with this class.
        # Each column that matches to one of the primary keys has its
        # primary attribute set to true
        def columns
          unless @columns
            @columns = connection.columns(table_name, "#{name} Columns")
            @columns.each {|column| column.primary = primary_keys.include?(column.name.to_sym)}
          end
          @columns
        end
          
        ## DEACTIVATED METHODS ##
        public
        # Lazy-set the sequence name to the connection's default.  This method
        # is only ever called once since set_sequence_name overrides it.
          def sequence_name #:nodoc:
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
    
          def reset_sequence_name #:nodoc:
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
    
          def set_primary_key(value = nil, &block)
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
       
        private
          def find_one(id, options)
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
       
          def find_some(ids, options)
            raise CompositeKeyError, CompositePrimaryKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
  
          def find_from_ids(ids, options)
            conditions = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
            # if ids is just a flat list, then its size must = primary_key.length (one id per primary key, in order)
            # if ids is list of lists, then each inner list must follow rule above
            
            if ids.first.is_a? String
              # find '2,1' -> ids = ['2,1']
              # find '2,1;7,3' -> ids = ['2,1;7,3']
              ids = ids.first.split(ID_SET_SEP).map {|id_set| id_set.split(ID_SEP).to_composite_ids}
              # find '2,1;7,3' -> ids = [['2','1'],['7','3']], inner [] are CompositeIds
            end
            ids = [ids.to_composite_ids] if not ids.first.kind_of?(Array)
            ids.each do |id_set| 
              unless id_set.is_a?(Array)
                raise "Ids must be in an Array, instead received: #{id_set.inspect}"
              end
              unless id_set.length == primary_keys.length
                raise "#{id_set.inspect}: Incorrect number of primary keys for #{class_name}: #{primary_keys.inspect}"
              end
            end
            
            # Let keys = [:a, :b]
            # If ids = [[10, 50], [11, 51]], then :conditions => 
            #   "(#{table_name}.a, #{table_name}.b) IN ((10, 50), (11, 51))"
            
            keys_sql = primary_keys.map {|key| "#{table_name}.#{key.to_s}"}.join(',')
            ids_sql  = ids.map {|id_set| id_set.map {|id| sanitize(id)}.join(',')}.join('),(')
            options.update :conditions => "(#{keys_sql}) IN ((#{ids_sql}))"
  
            result = find_every(options)
  
            if result.size == ids.size
              ids.size == 1 ? result[0] : result
            else
              raise RecordNotFound, "Couldn't find all #{name.pluralize} with IDs (#{ids_list})#{conditions}"
            end
          end

      end
    end
  end
end

module ActiveRecord
  ID_SEP = ','
  ID_SET_SEP = ';'

  class Base
    # Allows +attr_name+ to be the list of primary_keys, and returns the id
    # of the object
    # e.g. @object[@object.class.primary_key] => [1,1]
    def [](attr_name)
      if attr_name.is_a?(String) and attr_name != attr_name.split(ID_SEP).first
        attr_name = attr_name.split(ID_SEP)
      end
      attr_name.is_a?(Array) ?
        attr_name.map {|name| read_attribute(name)} :
        read_attribute(attr_name)
    end

    # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+.
    # (Alias for the protected write_attribute method).
    def []=(attr_name, value)
      if attr_name.is_a?(String) and attr_name != attr_name.split(ID_SEP).first
        attr_name = attr_name.split(ID_SEP)
      end
      if attr_name.is_a? Array
        value = value.split(ID_SEP) if value.is_a? String
        unless value.length == attr_name.length
          raise "Number of attr_names and values do not match"
        end
        #breakpoint
        [attr_name, value].transpose.map {|name,val| write_attribute(name.to_s, val)}
      else
        write_attribute(attr_name, value)
      end
    end

  end
end
