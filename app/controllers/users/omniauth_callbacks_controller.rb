class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    Rails.logger.info("Google callback triggered.")
    Rails.logger.info(request.env['omniauth.auth'])

    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: 'Something went wrong while signing in with Google.'
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Authentication failed, please try again."
  end
end
