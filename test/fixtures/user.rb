class User < ActiveRecord::Base
  has_many :readings
  has_many :articles, :through => :readings
  has_many :comments, :as => :person
  
  def find_custom_articles
    articles.find(:all, :conditions => ["name = ?", "Article One"])
  end
end
