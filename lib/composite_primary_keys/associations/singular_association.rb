module CompositePrimaryKeys
  module SingularAssociation
    extend ActiveSupport::Concern
    included do
      def get_records_with_cpk_support
        cpk_applies = (target && target.composite?) ||
          (owner && owner.composite?) ||
          (options[:primary_key] && options[:primary_key].kind_of?(Array)) || 
          (options[:foreign_key] && options[:foreign_key].kind_of?(Array))
        return scope.limit(1).to_a if cpk_applies
        get_records_without_cpk_support
      end
      alias_method_chain :get_records, :cpk_support
    end
  end
end

ActiveRecord::Associations::SingularAssociation.send(:include, CompositePrimaryKeys::SingularAssociation)
