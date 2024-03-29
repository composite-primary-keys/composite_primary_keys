class User < ActiveRecord::Base
  has_many :readings
  has_many :articles, :through => :readings

  has_many :comments, :as => :person
  has_one :first_comment, :as => :person, :class_name => "Comment"

  has_one :moderator, :foreign_key => :id, :inverse_of => :user
  delegate :admin, :to => :moderator, :allow_nil => true

  def find_custom_articles
    articles.where("name = ?", "Article One")
  end
end
