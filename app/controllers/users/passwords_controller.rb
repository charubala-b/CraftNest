# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :verify_authenticity_token

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    flash[:notice] = "If you have already registered, you will receive an email with instructions shortly."

    redirect_to new_session_path(resource_name)
  end
end
