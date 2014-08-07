module ActiveRecord
  module AttributeMethods
    module Read
      def read_attribute(attr_name)
        if attr_name.kind_of?(Array)
          attr_name.map {|name| read_attribute(name)}.to_composite_keys
        else
          # If it's cached, just return it
          # We use #[] first as a perf optimization for non-nil values. See https://gist.github.com/jonleighton/3552829.
          name = attr_name.to_s
          @attributes_cache[name] || @attributes_cache.fetch(name) {
            column = @column_types_override[name] if @column_types_override
            column ||= @column_types[name]

            return @attributes.fetch(name) {
              if name == 'id' && self.class.primary_key != name
                read_attribute(self.class.primary_key)
              end
            } unless column

            value = @attributes.fetch(name) {
              return block_given? ? yield(name) : nil
            }

            if self.class.cache_attribute?(name)
              @attributes_cache[name] = column.type_cast(value)
            else
              column.type_cast value
            end
          }
        end
      end
    end
  end
end