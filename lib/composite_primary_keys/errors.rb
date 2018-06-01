module CompositePrimaryKeys
  # = Composite Primary Keys Errors
  #
  # Generic Composite Primary Keys exception class.
  class CompositePrimaryKeysError < StandardError
  end

  # Raised when finder method receives incomplete arguments
  #
  #   class Department < ActiveRecord::Base
  #     self.primary_keys = :department_id, :location_id
  #   end
  #
  #   # A single integer can not be mapped to composite primary keys
  #   # this call raises a IncompleteArgumentsError
  #   Department.find(1)
  class IncompleteArgumentsError < CompositePrimaryKeysError
    def initialize(klass, primary_key, args)
      super <<-MSG.lstrip
      Can not map arguments to composite primary key
  args: #{args}
  primary_key: #{primary_key.inspect}
  class: #{klass}
      MSG
    end
  end
end
