require 'abstract_unit'
require 'fixtures/comment'
require 'fixtures/user'
require 'fixtures/employee'
require 'fixtures/hack'

class TestPolymorphic < Test::Unit::TestCase
  fixtures :users, :employees, :comments, :hacks
  
  def test_polymorphic_has_many
    comments = Hack.find('andrew').comments
    assert comments[0].person_id = 'andrew'
  end
  
  def test_polymorphic_has_one
    first_comment = Hack.find('andrew').first_comment
    assert first_comment.person_id = 'andrew'
  end

end
