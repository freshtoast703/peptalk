require "application_system_test_case"

class DeviseFlowsTest < ApplicationSystemTestCase
  test "user can sign up and header shows their name" do
    email = "system_signup_#{SecureRandom.hex(4)}@example.com"
    user = sign_up_user(email: email, password: "password123")

    # The header should show the user's first name (or email if not present)
    assert_text user.first_name.presence || user.email
    assert_text "Sign out"
  end

  test "user can sign in and sign out and header updates" do
    user = create_user(email: "system_signin_#{SecureRandom.hex(4)}@example.com", password: "password123", password_confirmation: "password123", first_name: "Fred")

    sign_in_user_via_ui(user: user, password: "password123")

    # Header should show the user's name and Sign out link
    assert_text "Fred"
    assert_text "Sign out"

    # Sign out via form submission to use DELETE
    page.execute_script(<<~JS)
      var f = document.createElement('form');
      f.method = 'POST';
      f.action = '#{destroy_user_session_path}';
      var m = document.createElement('input');
      m.setAttribute('name', '_method');
      m.setAttribute('value', 'delete');
      f.appendChild(m);
      document.body.appendChild(f);
      f.submit();
    JS

    assert_text "Sign in"
    assert_text "Sign up"
  end

  test "user can update account password via edit page" do
    user = create_user(email: "system_edit_#{SecureRandom.hex(4)}@example.com", password: "password123", password_confirmation: "password123", first_name: "Paula")

    sign_in_user_via_ui(user: user, password: "password123")

    # Change password
    change_password_via_ui(current_password: "password123", new_password: "newpassword123")

    # After update, Devise usually signs the user in; verify sign out link still present and name shown
    assert_text "Paula"
    assert_text "Sign out"

    # Now sign out and sign in with new password to verify change
    page.execute_script(<<~JS)
      var f = document.createElement('form');
      f.method = 'POST';
      f.action = '#{destroy_user_session_path}';
      var m = document.createElement('input');
      m.setAttribute('name', '_method');
      m.setAttribute('value', 'delete');
      f.appendChild(m);
      document.body.appendChild(f);
      f.submit();
    JS

    # Sign in with new password
    sign_in_user_via_ui(user: user, password: "newpassword123")
    assert_text "Paula"
    assert_text "Sign out"
  end
end
