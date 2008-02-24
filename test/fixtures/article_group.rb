class ArticleGroup < ActiveRecord::Base
  belongs_to :article
  belongs_to :group
end
