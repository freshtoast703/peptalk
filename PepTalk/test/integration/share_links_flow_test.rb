require "test_helper"

class ShareLinksFlowTest < ActionDispatch::IntegrationTest
  def setup
    @post = Post.create!(title: "Public Post", description: "Hello")
    @user = User.create!(first_name: "A", last_name: "B", email: "a@example.com", mobile_number: "123")
    @link = @post.share_links.create!(token: "validtoken", user: @user, expires_at: 1.day.from_now)
  end

  test "GET /s/:token returns the post content for valid token" do
    get share_link_path(@link.token)
    assert_response :success
    assert_match @post.title, response.body
  end

  test "GET /s/:token returns 404 for invalid token" do
    get share_link_path("nope")
    assert_response :not_found
  end

  test "GET /s/:token returns 404 for expired token" do
    expired = @post.share_links.create!(token: "expired", expires_at: 1.day.ago)
    get share_link_path(expired.token)
    assert_response :not_found
  end

  test "access_count increments on successful hit" do
    assert_difference("@link.reload.access_count", 1) do
      get share_link_path(@link.token)
      assert_response :success
    end
  end
end
