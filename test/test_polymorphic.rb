require File.expand_path('../abstract_unit', __FILE__)

class TestPolymorphic < ActiveSupport::TestCase
  fixtures :articles, :departments, :employees, :users, :comments

  def test_has_many
    user = users(:santiago)
    comments = user.comments
    assert_equal(user.id, comments[0].person_id)
  end

  def test_has_one
    user = users(:santiago)
    first_comment = user.first_comment
    assert_equal(user.id, first_comment.person_id)
  end

  def test_has_many_through
    department = departments(:accounting)
    comment = comments(:employee_comment)

    assert_equal(1, department.comments.size)
    assert_equal(comment, department.comments[0])
  end

  def test_has_many_through_2
    article = articles(:second)

    user = users(:santiago)
    assert_equal(user, article.user_commentators[0])

    user = users(:drnic)
    assert_equal(user, article.user_commentators[1])
  end

  def test_clear_has_many_through
    article = articles(:second)

    assert_equal(2, article.comments.size)
    article.user_commentators = []
    assert_equal(0, article.comments.size)
  end

  def test_polymorphic_has_many_with_polymorphic_name
    comments = UserWithPolymorphicName.find(1).comments
    assert_equal 1, comments[0].person_id
    assert_equal "User1", comments[0].person_type
  end
end
