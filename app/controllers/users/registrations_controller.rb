class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :redirect_if_authenticated, only: [:new, :create]
  
  def after_sign_up_path_for(resource)
    if resource.freelancer?
      freelancer_dashboard_path
    else
      client_dashboard_path
    end
  end
  def create
    build_resource(sign_up_params.except(:skill_ids, :new_skills))

    if resource.save
      new_skill_ids = process_new_skills(params[:user][:new_skills])
      all_skill_ids = Array(params[:user][:skill_ids]).map(&:to_i) + new_skill_ids
      assign_skills(resource, all_skill_ids.uniq)

      yield resource if block_given?
      set_flash_message! :notice, :signed_up_but_unconfirmed if is_flashing_format?

      redirect_to new_user_session_path, notice: "Account created successfully. Please log in."
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :new_skills, skill_ids: []])
  end

  def assign_skills(user, skill_ids)
    user.skill_assignments.destroy_all
    skill_ids.each do |skill_id|
      user.skill_assignments.create(skill_id: skill_id)
    end
  end

  def process_new_skills(raw_new_skills)
    raw_new_skills.to_s.split(',').map(&:strip).reject(&:blank?).map do |skill_name|
      Skill.find_or_create_by(skill_name: skill_name.downcase).id
    end
  end

  # private

  # def redirect_if_authenticated
  #   redirect_to after_sign_in_path_for(current_user), alert: "You are already signed in." if user_signed_in?
  # end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :new_skills, skill_ids: [])
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password, :role, :new_skills, skill_ids: [])
  end
end
