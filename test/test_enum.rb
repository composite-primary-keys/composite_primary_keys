require File.expand_path('../abstract_unit', __FILE__)

class TestEnum < ActiveSupport::TestCase
  fixtures :comments

  def test_enum_was
    comment = Comment.first
    assert_nil comment.shown
    puts "comment.changed_attributes = #{comment.changed_attributes.inspect}"
    comment.shown = :true
    puts "comment.changed_attributes = #{comment.changed_attributes.inspect}"
    assert_equal 'true', comment.shown
    assert_nil comment.shown_was

    comment.save

    comment.shown = :false
    assert_equal 'false', comment.shown
    assert_equal 'true', comment.shown_was
  end
end
