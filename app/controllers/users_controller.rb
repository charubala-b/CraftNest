class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: "Registered successfully!"
    else
      render :new
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user && user.password == params[:password]  # (no password hashing for now)
      session[:user_id] = user.id
      redirect_to dashboard_path, notice: "Logged in successfully"
    else
      flash[:alert] = "Invalid email or password"
      render :login  # or :new_login if you named the view that way
    end
  end

def login_user
  user = User.find_by(email: params[:email])

  if user && user.password == params[:password]
    session[:user_id] = user.id
    redirect_to dashboard_path, notice: "Logged in!"
  else
    flash[:alert] = "Invalid email or password"
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
