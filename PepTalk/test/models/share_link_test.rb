require "test_helper"

class ShareLinkTest < ActiveSupport::TestCase
  def setup
    @post = Post.create!(title: "P")
  end

  test "active scope includes unexpired and not revoked links" do
    active = @post.share_links.create!(token: "a1", expires_at: 1.day.from_now)
    expired = @post.share_links.create!(token: "a2", expires_at: 1.day.ago)
    revoked = @post.share_links.create!(token: "a3", revoked_at: Time.current)

    ids = ShareLink.active.pluck(:id)
    assert_includes ids, active.id
    assert_not_includes ids, expired.id
    assert_not_includes ids, revoked.id
  end
end
