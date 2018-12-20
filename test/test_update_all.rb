require File.expand_path('../abstract_unit', __FILE__)

class TestUpdateAll < ActiveSupport::TestCase
  fixtures :articles, :users

  def test_update_all
    first_article = Article.first
    users_count = first_article.users.count
    # limit forces a subquery
    first_article.users.limit(1).update_all(name: 'test')
    assert_equal(
      User.joins(readings: :article)
        .merge(Article.where(id: first_article))
        .where(name: 'test').count, users_count
    )
  end
end