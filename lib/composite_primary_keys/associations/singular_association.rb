module CompositePrimaryKeys
  module SingularAssociation
    def get_records
      cpk_applies = (target && target.composite?) ||
        (owner && owner.composite?) ||
        (options[:primary_key] && options[:primary_key].kind_of?(Array)) ||
        (options[:foreign_key] && options[:foreign_key].kind_of?(Array))
      return scope.limit(1).to_a if cpk_applies
      super
    end
  end
end

ActiveRecord::Associations::SingularAssociation.prepend CompositePrimaryKeys::SingularAssociation
