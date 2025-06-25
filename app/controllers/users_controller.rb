class UsersController < ApplicationController
  def new
    @user = User.new
    @skills = Skill.all
  end

def create
  @user = User.new(user_params.except(:skill_ids, :new_skills))
  @skills = Skill.all

  if @user.save
    all_skill_ids = process_all_skills(params[:user])
    all_skill_ids.each do |skill_id|
      @user.skill_assignments.create(skill_id: skill_id)
    end
    redirect_to login_path, notice: "Registered successfully!"
  else
    flash.now[:alert] = "Invalid info!"
    render :new
  end
end


  def login
    # renders login form
  end

  def login_user
    user = User.find_by(email: params[:email])

    if user && user.password == params[:password] # ⚠️ Plaintext password (consider bcrypt in production)
      session[:user_id] = user.id

      if user.client?
        redirect_to client_dashboard_path, notice: "Welcome, Client!"
      elsif user.freelancer?
        redirect_to freelancer_dashboard_path, notice: "Welcome, Freelancer!"
      else
        redirect_to root_path, alert: "Unknown role."
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :login
    end
  end

  private

def user_params
  params.require(:user).permit(
    :name,
    :email,
    :password,
    :role,
    :new_skills,
    skill_ids: []
  )
end


  # 🔧 Combines selected skill_ids and new comma-separated skills
  def process_all_skills(user_params)
    skill_ids = Array(user_params[:skill_ids]).reject(&:blank?).map(&:to_i)

    if user_params[:new_skills].present?
      new_skills = user_params[:new_skills].split(",").map(&:strip).reject(&:blank?)

      new_skills.each do |skill_name|
        skill = Skill.find_or_create_by(skill_name: skill_name.downcase)
        skill_ids << skill.id unless skill_ids.include?(skill.id)
      end
    end

    skill_ids
  end
end
