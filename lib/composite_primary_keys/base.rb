module CompositePrimayKeys
  module ActiveRecord #:nodoc:
    module Base #:nodoc:

      INVALID_FOR_COMPOSITE_KEYS = 'Not appropriate for composite primary keys'
      ID_SEP = ','
       
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        def set_primary_keys(*keys)
          @@primary_keys = []
          cattr_accessor :primary_keys 
          self.primary_keys = keys
          
          class_eval <<-EOV
            include CompositePrimayKeys::ActiveRecord::Base::InstanceMethods
            extend CompositePrimayKeys::ActiveRecord::Base::CompositeClassMethods
          EOV
        end
      end
     
      module InstanceMethods  
        
        # A model instance's primary keys is always available as model.ids
        # whether you name it the default 'id' or set it to something else.
        def id
          attr_names = self.class.primary_keys
          attr_names.map {|attr_name| read_attribute(attr_name)}
        end
        alias_method :ids, :id
        
        #id_to_s([1,2]) -> "1,2"
        #id_to_s([1,2], '-') -> "1-2"
        def id_to_s(ids, id_sep = CompositePrimayKeys::ActiveRecord::Base::ID_SEP)
          ids.map{|id| self.class.sanitize(id)}.join("#{id_sep}")
        end
  
        # Enables Active Record objects to be used as URL parameters in Action Pack automatically.
        def to_param
          id_to_s(ids)
        end
  
        def id_before_type_cast #:nodoc:
          # TODO
          read_attribute_before_type_cast(self.class.primary_key)
        end
  
        def quoted_id #:nodoc:
          # TODO
          quote(id, column_for_attribute(self.class.primary_key))
        end
  
        # Sets the primary ID.
        def id=(value)
          ids = id.split(value) if value.is_a?(String)
          unless ids.is_a?(Array) and ids.length == self.class.primary_keys.length
            raise "#{self.class}.id= requires #{self.class.primary_keys.length} ids"
          end
          ids.each {|id| write_attribute(self.class.primary_key , id)}
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
      end
      
      module CompositeClassMethods
        
        def primary_keys_to_s(sep = CompositePrimayKeys::ActiveRecord::Base::ID_SEP)
          primary_keys.map(&:to_s).join(sep)
        end
       
        #ids_to_s([[1,2],[7,3]]) -> "(1,2),(7,3)"
        #ids_to_s([[1,2],[7,3]], ',', ';', '', '') -> "1,2;7,3"
        def ids_to_s(ids, id_sep = CompositePrimayKeys::ActiveRecord::Base::ID_SEP, list_sep = ',', left_bracket = '(', right_bracket = ')')
          "#{left_bracket}#{ids.map{|id| sanitize(id)}.join('#{id_sep}')}#{right_bracket}"
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
          delete_all([ "(#{primary_keys_to_s}) IN (#{ids_to_s(ids)})" ])
        end
  
        # Destroys the record with the given +ids+ by instantiating the object and calling #destroy (all the callbacks are the triggered).
        # If an array of ids is provided, all of them are destroyed.
        def destroy(*ids)
          ids.first.is_a?(Array) ? ids.each { |id_set| destroy(id_set) } : find(ids).destroy
        end
       
        # Alias for the composite primary_keys accessor method
        def primary_key
          raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          # primary_keys
          # Initially invalidate the method to find places where its used
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
            raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
    
          def reset_sequence_name #:nodoc:
            raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
    
          def set_primary_key(value = nil, &block)
            raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
       
        private
          def find_one(id, options)
            raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
       
          def find_some(ids, options)
            raise CompositePrimayKeys::ActiveRecord::Base::INVALID_FOR_COMPOSITE_KEYS
          end
  
          def find_from_ids(ids, options)
            conditions = " AND (#{sanitize_sql(options[:conditions])})" if options[:conditions]
            # if ids is just a flat list, then its size must = primary_key.length (one id per primary key, in order)
            # if ids is list of lists, then each inner list must follow rule above
            #if ids.first.is_a?(String) - find '2,1' -> find_from_ids ['2,1']
            ids = ids[0].split(';').map {|id_set| id_set.split ','} if ids.first.is_a? String
            ids = [ids] if not ids.first.kind_of?(Array)
            
            ids.each do |id_set| 
              unless id_set.is_a?(Array)
                raise "Ids must be in an Array, instead received: #{id_set.inspect}"
              end
              unless id_set.length == primary_keys.length
                raise "Incorrect number of primary keys for #{class_name}: #{primary_keys.inspect}"
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
