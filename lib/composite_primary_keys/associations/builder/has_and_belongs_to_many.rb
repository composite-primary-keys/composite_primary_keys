module ActiveRecord
  module Associations
    module Builder
      class HasAndBelongsToMany # :nodoc:

        private

        def middle_options(join_model)
          middle_options = {}
          middle_options[:class_name] = "#{lhs_model.name}::#{join_model.name}"
          middle_options[:source] = join_model.left_reflection.name
          if options.key? :foreign_key
            middle_options[:foreign_key] = options[:foreign_key]
          end

          # CPK
          if options.key? :primary_key
            middle_options[:primary_key] = options[:primary_key]
          end

          middle_options
        end
      end
    end
  end
end
