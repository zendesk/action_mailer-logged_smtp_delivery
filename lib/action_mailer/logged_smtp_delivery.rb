require 'action_mailer'
require 'mail/network/delivery_methods/smtp'

class ActionMailer::LoggedSMTPDelivery < Mail::SMTP
  def initialize(settings)
    super
    self.settings[:tls] = (settings[:tls] != false)
    self.settings[:return_response] = true
    self.logger = settings[:logger]
  end

  def deliver!(mail)
    if logger = settings[:mail_file_logger]
      path = logger.log(mail.encoded)
      log mail, "stored at #{path}"
    end

    log_headers(mail)
    log mail, "sender: #{mail.sender}"
    log mail, "destinations: #{mail.destinations.inspect}"

    response = super

    mail.header[:smtp_response] = response.message
    log mail, "done #{response.inspect}"
  end

  private

  attr_accessor :logger

  def log_headers(mail)
    log mail, "#{log_header}: [#{mail[log_header]}]" if log_header
  end

  def log_header
    settings[:log_header]
  end

  def log(mail, message)
    logger.info("#{mail.message_id} #{message}")
  end
end

ActionMailer::Base.add_delivery_method :logged_smtp, ActionMailer::LoggedSMTPDelivery
