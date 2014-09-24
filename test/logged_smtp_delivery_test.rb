require_relative 'helper'

class LoggedSMTPDeliveryTest < MiniTest::Unit::TestCase
  class TestMailer < ActionMailer::Base
    include ActionMailer::LoggedSMTPDelivery

    self.delivery_method  = :logged_smtp
    self.logged_smtp_settings = {
      :adaptor => FakeSMTP,
      :mail_file_logger => MemoryLogger.new,
      :logger => Logger.new(StringIO.new)
    }

    def welcome
      mail(
        to: 'to@example.com',
        from: 'me@example.com',
        body: 'hello'
      )
    end
  end

  describe 'delivering via actionmailer' do
    def without_file_logger
      original_logger = TestMailer.logged_smtp_settings[:mail_file_logger]
      TestMailer.logged_smtp_settings[:mail_file_logger] = nil
      yield
    ensure
      TestMailer.logged_smtp_settings[:mail_file_logger] = original_logger
    end

    let(:mail_file_logger) { TestMailer.logged_smtp_settings[:mail_file_logger] }
    before do
      mail_file_logger.clear
      FakeSMTP.deliveries.clear
    end

    it 'logs the mail to a file when the mail file logger is available' do
      TestMailer.welcome.deliver
      mail_file_logger.messages.pop.gsub(/(Date|Message-ID):.*\r\n/, '').must_equal "From: me@example.com\r\nTo: to@example.com\r\nSubject: Welcome\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\nhello"
    end

    it 'does not logs without file logger' do
      without_file_logger do
        assert TestMailer.welcome.deliver
        mail_file_logger.messages.must_equal []
      end
    end

    it 'delivers the mail' do
      TestMailer.welcome.deliver
      mail = FakeSMTP.deliveries.last
      mail[0].gsub(/(Date|Message-ID):.*\r\n/, '').must_equal "From: me@example.com\r\nTo: to@example.com\r\nSubject: Welcome\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\nhello"
      mail[1].must_equal "me@example.com"
      mail[2].must_equal ["to@example.com"]
    end
  end

  describe 'SMTP Delivery' do
    before do
      @settings = { :adaptor => FakeSMTP }
      @mail = Mail.new.tap do |mail|
        mail.message_id = '<12345@example.com>'
      end
      @log = StringIO.new
      logger = Logger.new(@log)
      @delivery = ActionMailer::LoggedSMTPDelivery::SMTPDelivery.new(@mail, @settings, logger)
      logger.formatter = lambda { |severity, datetime, progname, msg| msg }
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

      assert_equal '12345@example.com hello', @log.string
    end

    it 'logs headers when the log header is provided' do
      @delivery.log_headers
      assert_equal '', @log.string

      @delivery.settings[:log_header] = 'X-Delivery-Context'
      @delivery.mail['X-Delivery-Context'] = 'hello-33'
      @delivery.log_headers

      assert_equal '12345@example.com X-Delivery-Context: [hello-33]', @log.string
    end

    it 'sends the mail' do
      @mail.from = 'me@example.com'
      @mail.to   = 'to@example.com'
      @mail.cc   = 'cc@example.com'
      @mail.bcc  = 'bcc@example.com'
      @mail.body = 'hello'
      @delivery.perform

      mail = FakeSMTP.deliveries.last
      mail[0].gsub(/(Date|Message-ID):.*\r\n/, '').must_equal "From: me@example.com\r\nTo: to@example.com\r\nCc: cc@example.com\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\nhello"
      mail[1].must_equal "me@example.com"
      mail[2].must_equal ["to@example.com", "cc@example.com", "bcc@example.com"]
    end

    it 'does not include BCC addresses in the message' do
      @mail.bcc = 'bcc@example.com'
      assert_equal false, @delivery.message.include?('bcc@example.com')
    end
  end
end
