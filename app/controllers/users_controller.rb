class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Registered successfully!"
    else
      flash.now[:alert] = "Invalid info !"
      render :new
    end
  end

  def login
  end


  def login_user
    user = User.find_by(email: params[:email])

    if user && user.password == params[:password]
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

  def logout
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out!"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :skills)
  end
end

