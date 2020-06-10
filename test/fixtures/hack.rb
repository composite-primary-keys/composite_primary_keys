class Hack < ActiveRecord::Base
  has_many :comments, :as => :person
  has_many :users, :through => :comments, :source => :person, :source_type => "User"

  has_one :first_comment, :as => :person, :class_name => "Comment"
end