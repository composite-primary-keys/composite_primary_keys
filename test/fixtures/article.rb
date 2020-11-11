class Article < ActiveRecord::Base
  validates :id, uniqueness: true, numericality: true, allow_nil: true, allow_blank: true, on: :create
  has_many :readings, :dependent => :delete_all
  has_many :users, :through => :readings

  has_many :comments, :dependent => :delete_all
  has_many :employee_commentators, :through => :comments, :source => :person, :source_type => :employee
  has_many :user_commentators, :through => :comments, :source => :person, :source_type => "User"
end

