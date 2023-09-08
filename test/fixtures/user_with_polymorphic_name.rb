class UserWithPolymorphicName < ActiveRecord::Base
  self.table_name = "users"

  has_many :comments, :as => :person

  def self.polymorphic_name
    "User1"
  end
end
