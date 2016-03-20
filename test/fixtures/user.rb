class User < ActiveRecord::Base
  has_many :readings
  has_many :articles, :through => :readings
  has_many :comments, :as => :person
  has_many :hacks, :through => :comments, :source => :hack
  has_many :persons, :through => :comments, :source_type => 'User'
  
  def find_custom_articles
    articles.where("name = ?", "Article One")
  end
end
