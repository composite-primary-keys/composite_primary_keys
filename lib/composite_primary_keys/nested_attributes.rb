module ActiveRecord
  module NestedAttributes
    def assign_nested_attributes_for_collection_association(association_name, attributes_collection, assignment_opts = {})
      options = self.nested_attributes_options[association_name]

      unless attributes_collection.is_a?(Hash) || attributes_collection.is_a?(Array)
        raise ArgumentError, "Hash or Array expected, got #{attributes_collection.class.name} (#{attributes_collection.inspect})"
      end

      if options[:limit] && attributes_collection.size > options[:limit]
        raise TooManyRecords, "Maximum #{options[:limit]} records are allowed. Got #{attributes_collection.size} records instead."
      end

      if attributes_collection.is_a? Hash
        keys = attributes_collection.keys
        attributes_collection = if keys.include?('id') || keys.include?(:id)
                                  Array.wrap(attributes_collection)
                                else
                                  attributes_collection.values
                                end
      end

      association = association(association_name)

      existing_records = if association.loaded?
                           association.target
                         # CPK
                         elsif association.reflection.klass.composite?
                           attributes_collection.map do |attribute_collection|
                             attribute_ids = attribute_collection['id'] || attribute_collection[:id]
                             if attribute_ids
                               ids = CompositePrimaryKeys::CompositeKeys.parse(attribute_ids)
                               eq_predicates = association.klass.primary_key.zip(ids).map do |primary_key, value|
                                 association.klass.arel_table[primary_key].eq(value)
                               end
                               association.scoped.where(*eq_predicates).to_a
                             else
                               []
                             end
                           end.flatten.compact
                         else
                           attribute_ids = attributes_collection.map {|a| a['id'] || a[:id] }.compact
                           attribute_ids.empty? ? [] : association.scoped.where(association.klass.primary_key => attribute_ids)
                         end

      attributes_collection.each do |attributes|
        attributes = attributes.with_indifferent_access

        if attributes['id'].blank?
          unless reject_new_record?(association_name, attributes)
            association.build(attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
          end
        elsif existing_record = existing_records.detect { |record| record.id.to_s == attributes['id'].to_s }
          unless association.loaded? || call_reject_if(association_name, attributes)
            # Make sure we are operating on the actual object which is in the association's
            # proxy_target array (either by finding it, or adding it if not found)
            target_record = association.target.detect { |record| record == existing_record }

            if target_record
              existing_record = target_record
            else
              association.add_to_target(existing_record)
            end

          end

          if !call_reject_if(association_name, attributes)
            assign_to_or_mark_for_destruction(existing_record, attributes, options[:allow_destroy], assignment_opts)
          end
        elsif assignment_opts[:without_protection]
          association.build(attributes.except(*unassignable_keys(assignment_opts)), assignment_opts)
        else
          raise_nested_attributes_record_not_found(association_name, attributes['id'])
        end
      end
    end
  end
end
