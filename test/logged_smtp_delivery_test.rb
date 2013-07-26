require_relative 'helper'
require 'action_mailer/logged_smtp_delivery'
require 'logger'

class LoggedSMTPDeliveryTest < MiniTest::Unit::TestCase

  class TestMailer < ActionMailer::Base
    include ActionMailer::LoggedSMTPDelivery

    self.mail_file_logger = MemoryLogger.new
    self.logger           = Logger.new(StringIO.new)
    self.delivery_method  = :logged_smtp
    self.smtp_settings    = { :adaptor => FakeSMTP }

    def welcome
      recipients 'to@example.com'
      from       'me@example.com'
      body       'hello'

      # Keep the message simple and consistent between test runs
      headers['mime-version'] = ''
      charset nil
      headers['date'] = ''
    end

  end

  describe 'delivering via actionmailer' do
    before do
      TestMailer.mail_file_logger.clear
      FakeSMTP.deliveries.clear
    end

    it 'logs the mail to a file when the mail file logger is available' do
      TestMailer.deliver_welcome
      assert_equal "From: me@example.com\r\nTo: to@example.com\r\nContent-Type: text/plain\r\n\r\nhello", TestMailer.mail_file_logger.messages.last
      TestMailer.mail_file_logger.messages.clear

      original_logger = TestMailer.mail_file_logger
      TestMailer.mail_file_logger = nil
      assert TestMailer.deliver_welcome
      TestMailer.mail_file_logger = original_logger
    end

    it 'delivers the mail' do
      TestMailer.deliver_welcome
      delivery = ["From: me@example.com\r\nTo: to@example.com\r\nContent-Type: text/plain\r\n\r\nhello", "me@example.com", ["to@example.com"]]

      assert_equal delivery, FakeSMTP.deliveries.last
    end

  end

  describe 'SMTP Delivery' do
    before do
      @settings = { :adaptor => FakeSMTP }
      @mail     = TMail::Mail.new.tap do |mail|
        mail.message_id = '<12345@example.com>'
      end
      @delivery = ActionMailer::LoggedSMTPDelivery::SMTPDelivery.new(@mail, @settings)
      @log      = StringIO.new
      @delivery.logger = Logger.new(@log)
      @delivery.logger.formatter = lambda { |severity, datetime, progname, msg| msg }
    end

    it 'has the sender via the first from address' do
      @mail.from = [ 'a@example.com', 'b@example.com' ]
      assert_equal 'a@example.com', @delivery.sender
    end

    it 'has a list of destination addresses' do
      @mail.to  = 'to@example.com'
      @mail.cc  = 'cc@example.com'
      @mail.bcc = 'bcc@example.com'

      assert_equal [ 'to@example.com', 'cc@example.com','bcc@example.com' ], @delivery.destinations
    end

    it 'has an smtp connection' do
      @delivery.settings[:address] = 'example.com'
      @delivery.settings[:port]    = 26

      smtp = @delivery.smtp
      assert_equal 26,            smtp.port
      assert_equal 'example.com', smtp.address
      assert_equal true,          smtp.starttls_auto?

      @delivery.settings[:tls]    = false
      assert_equal false,         @delivery.smtp.starttls_auto?
    end

    it 'logs with the mail message id' do
      @delivery.log 'hello'

      assert_equal '<12345@example.com> hello', @log.string
    end

    it 'logs headers when the log header is provided' do
      @delivery.log_headers
      assert_equal '', @log.string

      @delivery.settings[:log_header] = 'X-Delivery-Context'
      @delivery.mail['X-Delivery-Context'] = 'hello-33'
      @delivery.log_headers

      assert_equal '<12345@example.com> X-Delivery-Context: [hello-33]', @log.string
    end

    it 'sends the mail' do
      @mail.from = 'me@example.com'
      @mail.to   = 'to@example.com'
      @mail.cc   = 'cc@example.com'
      @mail.bcc  = 'bcc@example.com'
      @mail.body = 'hello'
      message = [
        "From: me@example.com\r\nTo: to@example.com\r\nCc: cc@example.com\r\nMessage-Id: <12345@example.com>\r\n\r\nhello",
        "me@example.com",
        ["to@example.com", "cc@example.com", "bcc@example.com"]
      ]
      @delivery.perform

      assert_equal message, FakeSMTP.deliveries.last
    end

    it 'does not include BCC addresses in the message' do
      @mail.bcc = 'bcc@example.com'
      assert_equal false, @delivery.message.include?('bcc@example.com')
    end

  end

end
