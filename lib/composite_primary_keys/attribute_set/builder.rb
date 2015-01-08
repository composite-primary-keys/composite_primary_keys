module ActiveRecord
  class AttributeSet # :nodoc:
    class Builder # :nodoc:
      def build_from_database_with_cpk_support(values = {}, additional_types = {})
        if always_initialized.kind_of? Array
          always_initialized.each do |column|
            if !values.key?(column)
              values[always_initialized] = nil
            end
          end

          attributes = LazyAttributeHash.new(types, values, additional_types)
          AttributeSet.new(attributes)
        else
          build_from_database_without_cpk_support(values, additional_types)
        end
      end

      alias_method_chain :build_from_database, :cpk_support
    end
  end
end
