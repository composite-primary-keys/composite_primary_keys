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
    # Error when building the relation passing pk_user.id as pk_post.id
    assert_equal("SELECT `pk_posts`.* FROM `pk_posts` WHERE `pk_posts`.`id` = 1234 AND `pk_posts`.`pk_account_id` = #{pk_account.id}", PkPost.where(pk_user: PkUser.where(name: 'baz').limit(1)).to_sql)
  end

  def test_primary_key_vs_id
    pk_account = PkAccount.create!(name: 'foo')

    pk_user1_id = 1001
    pk_user1_pkey = [pk_user1_id, pk_account.id]

    pk_user2_id = 1002
    pk_user2_pkey = [pk_user2_id, pk_account.id]

    pk_user1 = PkUser.create(name: 'bar', id: pk_user1_pkey)
    pk_user2 = PkUser.create(name: 'baz', id:pk_user2_pkey)

    # .pluck vs .map
    assert_equal([pk_user1_id, pk_user2_id], PkUser.where(pk_account: pk_account).pluck(:id))
    assert_equal([pk_user1_pkey, pk_user2_pkey], PkUser.where(pk_account: pk_account).map(&:id))
  end
end
