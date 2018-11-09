class Author < ActiveRecord::Base
  belongs_to :reading, counter_cache: :rating
end
