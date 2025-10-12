class ShareLink < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true

  validates :token, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where('expires_at IS NULL OR expires_at > ?', Time.current) }

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end
end
