module CompositePrimaryKeys
  module CollectionAssociation
    extend ActiveSupport::Concern
    included do
      def get_records_with_cpk_support
        cpk_applies = (target && target.respond_to?(:composite?) && target.composite?) || (owner && owner.respond_to?(:composite?) && owner.composite?)
        return scope.to_a if cpk_applies
        get_records_without_cpk_support
      end
      alias_method_chain :get_records, :cpk_support
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.send(:include, CompositePrimaryKeys::CollectionAssociation)