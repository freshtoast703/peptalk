require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Helper to sign up a new user via the UI
  def sign_up_user(email: nil, password: "password123", first_name: "System", last_name: "User")
    email ||= "system_signup_#{SecureRandom.hex(4)}@example.com"
    visit new_user_registration_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    fill_in "Password confirmation", with: password
    click_button "Sign up"
    # Devise should show a success message on sign up. Wait for it and then return the user record.
    assert_text(/signed up successfully|welcome/i)
    User.find_by!(email: email)
  end

  # Helper to sign in a user via the UI
  def sign_in_user_via_ui(user:, password: "password123")
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_button "Log in"
  end

  # Helper to navigate to account edit and change password
  def change_password_via_ui(current_password: "password123", new_password: "newpassword123")
    # Prefer navigating to the edit page via header link to ensure correct session/navigation
    if page.has_link?("Edit account")
      click_link "Edit account"
    else
      visit edit_user_registration_path
    end

    # Wait for the edit form to be present and the heading to appear
    assert_text "Edit"

    # Fill password fields using visible labels where possible
    if page.has_field?("Password", wait: 2)
      fill_in "Password", with: new_password
    elsif page.has_field?("user[password]", wait: 2)
      fill_in "user[password]", with: new_password
    end

    if page.has_field?("Password confirmation", wait: 1)
      fill_in "Password confirmation", with: new_password
    elsif page.has_field?("user[password_confirmation]", wait: 1)
      fill_in "user[password_confirmation]", with: new_password
    end

    if page.has_field?("Current password", wait: 2)
      fill_in "Current password", with: current_password
    elsif page.has_field?("user[current_password]", wait: 2)
      fill_in "user[current_password]", with: current_password
    else
      raise Capybara::ElementNotFound, "Could not find current password field on account edit page"
    end

    click_button "Update"
  end
end
