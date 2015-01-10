module ActiveRecord
  module Core
    def initialize_dup(other) # :nodoc:
      @attributes = @attributes.dup
      # CPK
      # @attributes.reset(self.class.primary_key)
      Array(self.class.primary_key).each {|key| @attributes.reset(key)}

      run_callbacks(:initialize) unless _initialize_callbacks.empty?

      @aggregation_cache = {}
      @association_cache = {}

      @new_record  = true
      @destroyed   = false

      super
    end
    
    
  end
end


module CompositePrimaryKeys
  module ActiveRecordCoreConcernIncludedExtension
    extend ActiveSupport::Concern

    included do
      def self.find(*ids)
        if composite?
          super(cpk_parse_ids(ids))
        else
          super
        end
      end
      
      private
      def self.cpk_parse_ids(ids)
        result = []
        ids.each do |id|
          if id.is_a?(String)
            if id.index(",")
              result << [id.split(",")]
            else
              result << [id]
            end
          elsif id.is_a?(Array) && id.count > 1 && id.first.to_s.index(",")
            result << id.map{|subid| subid.split(",")}
          else
            result << [id]
          end
        end
        
        copy_to_find_depth, depth = result.dup, -1

        until copy_to_find_depth == result.flatten
          depth += 1
          copy_to_find_depth = copy_to_find_depth.flatten(1)
        end
        
        result = result.flatten(depth)
        return result
      end
    end
  end
end
  
ActiveRecord::Base.send(:include, CompositePrimaryKeys::ActiveRecordCoreConcernIncludedExtension)