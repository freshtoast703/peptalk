class ShareLinksController < ApplicationController
  # Publicly accessible endpoint for shared posts — do not require auth here.
  # Admin actions (create/destroy) assume there's some authentication in place
  # (Devise `authenticate_user!` or similar). We call it conditionally if defined.
  before_action :require_login_for_admin!, only: [:create, :destroy]
  def show
    @share_link = ShareLink.active.find_by(token: params[:token])

    return head :not_found unless @share_link

    @post = @share_link.post

    # atomic increment
    ShareLink.where(id: @share_link.id)
             .update_all('access_count = access_count + 1, last_accessed_at = CURRENT_TIMESTAMP')

    render 'posts/show'
  end

  # Admin actions (optional): create/destroy
  def create
    post = Post.find(params.require(:post_id))
    token = params[:token] || SecureRandom.urlsafe_base64(24)
    link = post.share_links.create!(token: token, user: (defined?(current_user) ? current_user : nil), expires_at: params[:expires_at], permissions: params[:permissions])

    respond_to do |format|
      format.json { render json: { token: link.token, url: share_link_url(link.token) } }
      format.html { redirect_to post_path(post), notice: "Share link created" }
    end
  end

  def destroy
    link = ShareLink.find(params.require(:id))
    link.update!(revoked_at: Time.current)

    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_back fallback_location: post_path(link.post), notice: "Share link revoked" }
    end
  end

  private

  def require_login_for_admin!
    # If your app provides an `authenticate_user!` helper (e.g., Devise), prefer it.
    if respond_to?(:authenticate_user!)
      authenticate_user!
    else
      # If there's no authenticate_user! helper installed, require presence of current_user
      head :unauthorized unless defined?(current_user) && current_user.present?
    end
  end
end
