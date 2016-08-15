class NotificationMailer < ActionMailer::Base
  default from: "info@helpalife.in"

  def notify_need(user,need)
    @user = user
    @need = need
    @url  = need_url(need)
    mail(to: @user.email, subject: "#{need.patient_name}, Needs #{need.blood_group} blood.")
  end

  def welcome(user,host_protocol,host_with_port)
    @user = user
    @host_with_port = host_with_port
    @host_protocol = host_protocol
    mail(to: @user.email, subject: "Welcome to Voluntary Blood Donors online Community")
  end

  def contact_email(name,message,from_email,subject)
    @name = name
    @message = message
    mail(to: "samuels410@gmail.com", from: from_email, subject: subject)
  end

  def post_notify(post)
    @post = post
    @url = blog_post_url(@post)
    @recipients = User.receive_newsletter
    emails = @recipients.collect(&:email).join(",")

    mail(to: emails, subject: "Helpalife Blog: #{@post.title}")
  end

  def event_registration_confirmation(user,host_protocol,host_with_port)
    @user = user
    @host_with_port = host_with_port
    @host_protocol = host_protocol
      mail(to: @user.email, subject: "Helpalife.in | DEFINE YOUNG INDIA contest registration confirmation")
  end


end
