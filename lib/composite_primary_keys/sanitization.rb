module ActiveRecord
  module Sanitization
    module ClassMethods

      protected
      # Accepts a hash of SQL conditions and replaces those attributes
      # that correspond to a {#composed_of}[rdoc-ref:Aggregations::ClassMethods#composed_of]
      # relationship with their expanded aggregate attribute values.
      #
      # Given:
      #
      #   class Person < ActiveRecord::Base
      #     composed_of :address, class_name: "Address",
      #       mapping: [%w(address_street street), %w(address_city city)]
      #   end
      #
      # Then:
      #
      #   { address: Address.new("813 abc st.", "chicago") }
      #   # => { address_street: "813 abc st.", address_city: "chicago" }
      silence_warnings do
        def expand_hash_conditions_for_aggregates(attrs)
          expanded_attrs = {}
          attrs.each do |attr, value|
            # CPK
            # if aggregation = reflect_on_aggregation(attr.to_sym)
            if attr.is_a?(CompositePrimaryKeys::CompositeKeys)
              attr.each_with_index do |key,i|
                expanded_attrs[key] = value.respond_to?(:flatten) ? value.flatten[i] : value
              end
            elsif aggregation = reflect_on_aggregation(attr.to_sym)
              mapping = aggregation.mapping
              mapping.each do |field_attr, aggregate_attr|
                if mapping.size == 1 && !value.respond_to?(aggregate_attr)
                  expanded_attrs[field_attr] = value
                else
                  expanded_attrs[field_attr] = value.send(aggregate_attr)
                end
              end
            else
              expanded_attrs[attr] = value
            end
          end
          expanded_attrs
        end

        def quoted_id
          # CPK
          # self.class.quote_value(@attributes[self.class.primary_key].value_for_database)
          if self.composite?
            [self.class.primary_keys, ids].transpose.map { |attr_name,id|
              self.class.quote_value(@attributes[attr_name].value_for_database)
            }
          else
            self.class.quote_value(@attributes[self.class.primary_key].value_for_database)
          end
        end
      end
    end
  end
end