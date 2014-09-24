require 'action_mailer'
require 'net/smtp'

module ActionMailer::LoggedSMTPDelivery
  class Mailer
    def initialize(settings)
      @settings = settings
    end

    def deliver!(mail)
      delivery = SMTPDelivery.new(mail, @settings, @settings.fetch(:logger))

      if logger = @settings[:mail_file_logger]
        path = logger.log(mail.encoded)
        delivery.log "stored at #{path}"
      end

      delivery.perform
    end
  end

  class SMTPDelivery
    attr_reader   :mail, :settings, :logger

    def initialize(mail, settings, logger)
      @mail         = mail
      @settings     = settings
      @logger       = logger
    end

    def perform
      log_headers
      log "sender: #{sender}"
      log "destinations: #{destinations.inspect}"

      smtp.start(*settings.values_at(:domain, :user_name, :password, :authentication)) do |session|
        response = session.send_message(message, sender, destinations)
        log "done #{response.inspect}"
      end
    end

    def destinations
      mail.destinations
    end

    def message
      original_bcc = mail.bcc
      mail.bcc     = nil
      mail.encoded
    ensure
      mail.bcc = original_bcc
    end

    def sender
      mail.from.first
    end

    def log_header
      settings[:log_header]
    end

    def smtp
      smtp_adaptor.new(settings[:address], settings[:port]).tap do |smtp|
        smtp.enable_starttls_auto if enable_tls?
      end
    end

    def log_headers
      log "#{log_header}: [#{mail[log_header]}]" if log_header
    end

    def log(message)
      logger.info("#{mail.message_id} #{message}")
    end

    def enable_tls?
      settings[:tls] != false
    end

    def smtp_adaptor
      settings[:adaptor] || Net::SMTP
    end
  end
end

ActionMailer::Base.add_delivery_method :logged_smtp, ActionMailer::LoggedSMTPDelivery::Mailer
