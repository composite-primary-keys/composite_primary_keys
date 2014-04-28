module CompositePrimaryKeys
  module ActiveRecord
    module Overides
 
      # This override ensures that pkeys are set on the instance when records are created.
      # However, while ActiveRecord::Persistence defines a create_record method
      # the call in create_or_update is actually calling the method create_record in the Dirty concern
      # which removes the pkey attrs and also sets updated/created at timestamps
      # For some reason when we overide here we lose dirty!
      # So, for now, timestamps are recorded explicitly
      def create_record(attribute_names = nil)
        record_timestamps!
        attribute_names ||= keys_for_partial_write
        attributes_values = arel_attributes_with_values_for_create(attribute_names)

        new_id = self.class.unscoped.insert attributes_values
        self.id = new_id if self.class.primary_key

        @new_record = false
        id
      end

      def record_timestamps!
        if self.record_timestamps
          current_time = current_time_from_proper_timezone

          all_timestamp_attributes.each do |column|
            if respond_to?(column) && respond_to?("#{column}=") && self.send(column).nil?
              write_attribute(column.to_s, current_time)
            end
          end
        end
      end
    end
  end
end

