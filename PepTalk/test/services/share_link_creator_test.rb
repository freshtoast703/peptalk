require "test_helper"

class ShareLinkCreatorTest < ActiveSupport::TestCase
  def setup
    @post = Post.create!(title: "Hello")
    @user = User.create!(first_name: "A", last_name: "B", email: "a@example.com", mobile_number: "123")
  end

  test "creates a share link with token and associations" do
    link = ShareLinkCreator.new(post: @post, user: @user, expires_at: 1.day.from_now).call
    assert link.persisted?
    assert_equal @post, link.post
    assert_equal @user, link.user
    assert link.token.present?
    assert link.expires_at.present?
  end

  test "retries on token collision and generates a different token" do
    existing = @post.share_links.create!(token: 'fixedtoken', user: @user)
    creator = ShareLinkCreator.new(post: @post, user: @user, token: 'fixedtoken', attempts: 3)
    link = creator.call
    assert link.persisted?
    assert_not_equal 'fixedtoken', link.token
  end

  test "raises when collisions exceed attempts" do
    existing = @post.share_links.create!(token: 'fixedtoken', user: @user)
    creator = ShareLinkCreator.new(post: @post, user: @user, token: 'fixedtoken', attempts: 1)
    assert_raises(ActiveRecord::RecordNotUnique) { creator.call }
  end
end
