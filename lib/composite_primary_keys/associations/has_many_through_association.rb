module ActiveRecord
  module Associations
    class HasManyThroughAssociation


      def through_records_for(record)
        # CPK
        # attributes = construct_join_attributes(record)
        # candidates = Array.wrap(through_association.target)
        # candidates.find_all do |c|
        #   attributes.all? do |key, value|
        #     c.public_send(key) == value
        #   end
        # end
        if record.composite?
          candidates = Array.wrap(through_association.target)
          candidates.find_all { |c| c.attributes.slice(*source_reflection.association_primary_key) == record.ids_hash }
        else
          attributes = construct_join_attributes(record)
          candidates = Array.wrap(through_association.target)
          candidates.find_all do |c|
            attributes.all? do |key, value|
              c.public_send(key) == value
            end
          end
        end
      end
    end
  end
end
