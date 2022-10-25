class OtherUser < ActiveRecord::Base
  self.primary_key = :id, :other_id

  has_many :readings
  has_many :articles, :through => :readings

  has_many :comments, :as => :person,
    # We intentionally redefine primary key for test purposes.
    # https://github.com/composite-primary-keys/composite_primary_keys/issues/455
    inverse_of: :person,
    :primary_key =>  [:id, :other_id],
    :foreign_key => [:person_id, :other_id]
  has_one :first_comment, :as => :person, :class_name => "Comment"

  def find_custom_articles
    articles.where("name = ?", "Article One")
  end
end
