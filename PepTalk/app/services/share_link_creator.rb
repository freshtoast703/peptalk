class ShareLinkCreator
  DEFAULT_TOKEN_BYTES = 24

  def initialize(post:, user: nil, expires_at: nil, permissions: 'read', token: nil, attempts: 5)
    @post = post
    @user = user
    @expires_at = expires_at
    @permissions = permissions
    @token = token
    @attempts = attempts
  end

  # Returns the created ShareLink or raises ActiveRecord::RecordNotUnique
  def call
    retries = 0
    begin
      token = @token || generate_token
      link = @post.share_links.create!(token: token, user: @user, expires_at: @expires_at, permissions: @permissions)
      link
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
      # On some adapters (and because of model-level uniqueness validation)
      # creating a record with a duplicate token may raise RecordInvalid with
      # a uniqueness validation error instead of a DB-level RecordNotUnique.
      dup_error = if e.is_a?(ActiveRecord::RecordInvalid)
        e.record.errors.details[:token].any? { |d| d[:error] == :taken }
      else
        true
      end

      raise unless dup_error

      retries += 1
      # If we've exhausted retries, raise a DB-level uniqueness error to match
      # callers that expect ActiveRecord::RecordNotUnique on failure.
      if retries >= @attempts
        raise ActiveRecord::RecordNotUnique, "failed to generate unique token after #{@attempts} attempts"
      end

      @token = nil
      retry
    end
  end

  private

  def generate_token
    SecureRandom.urlsafe_base64(DEFAULT_TOKEN_BYTES)
  end
end
