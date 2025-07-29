class UserMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def welcome_email(user)
    @user = user
    @url = 'https://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My App!')
  end
end
