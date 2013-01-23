class UserMailer < ActionMailer::Base
  default from: "sixawayapp@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = "#{SITE_URL}/users/#{user.activation_token}/activate"
    mail(:to => user.email,
         :subject => "6 Away - You are just one step away from meeting someone cool!")
  end
    
  def activation_success_email(user)
    @user = user
    @url  = "#{SITE_URL}/login"
    mail(:to => user.email,
         :subject => "6 Away - Your account has been activated")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    @url = "#{SITE_URL}/password_resets/#{user.reset_password_token}/edit"
    mail(:to => user.email,
         :subject => "6 Away - Your password has been reset")
  end

end
