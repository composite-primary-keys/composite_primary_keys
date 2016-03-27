module CompositePrimaryKeys
  module CollectionAssociation
    def get_records
      cpk_applies = (target && target.respond_to?(:composite?) && target.composite?) || (owner && owner.respond_to?(:composite?) && owner.composite?)
      return scope.to_a if cpk_applies
      super
    end
  end
end

ActiveRecord::Associations::CollectionAssociation.prepend CompositePrimaryKeys::CollectionAssociation