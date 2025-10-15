ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Include Devise test helpers for controller and integration tests
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

module TestHelpers
  def create_user(attrs = {})
    defaults = { first_name: "Test", last_name: "User", email: "test_#{SecureRandom.hex(4)}@example.com", mobile_number: "1234567890", password: "password123", password_confirmation: "password123" }
    User.create!(defaults.merge(attrs))
  end

  def sign_in_user(user = nil)
    user ||= create_user
    sign_in user
    user
  end
end

class ActiveSupport::TestCase
  include TestHelpers
end
