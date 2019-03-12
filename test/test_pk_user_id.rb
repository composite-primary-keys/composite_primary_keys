require File.expand_path('../abstract_unit', __FILE__)

class TestPkUserId < ActiveSupport::TestCase

  def test_success
    pk_account = PkAccount.create!(name: 'foo')
    pk_user = pk_account.pk_users.create!(name: 'bar')

    assert_raises(ActiveRecord::UnknownAttributeError) do
      pk_user.pk_posts.create!(title: 'title1')
    end

    assert_nil(pk_user.attributes['id'])
    assert_raise(ActiveRecord::NotNullViolation) do
      PkPost.create!(title: 'title1', pk_user: pk_user)
    end

    pk_user2 = PkUser.create(name: 'baz', id: [1234, pk_account.id])

    PkPost.create!(title: 'title1', pk_user_id: pk_user2.attributes['id'], pk_account_id: pk_account.id)

    assert_equal(1, PkPost.count)
    assert_equal("SELECT `pk_posts`.* FROM `pk_posts` WHERE `pk_posts`.`pk_user_id` = 1234 AND `pk_posts`.`pk_account_id` = #{pk_account.id}", PkPost.where(pk_user: pk_user2).to_sql)
    assert_equal("SELECT `pk_posts`.* FROM `pk_posts` WHERE `pk_posts`.`id` = 1234 AND `pk_posts`.`pk_account_id` = #{pk_account.id}", PkPost.where(pk_user: PkUser.where(name: 'baz').limit(1)).to_sql)
  end
end
