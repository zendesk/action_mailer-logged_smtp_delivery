require_relative 'helper'

class LoggedSMTPDeliveryTest < Minitest::Test
  class TestMailer < ActionMailer::Base
    self.delivery_method = :logged_smtp

    def welcome(extra={})
      mail({
        "Message-ID" => '12345@example.com',
        "Date" => "2000-01-01",
        to: 'to@example.com',
        from: 'me@example.com',
        body: 'hello'
      }.merge(extra))
    end
  end

  describe 'delivery' do
    let(:mail_file_logger) { MemoryLogger.new }
    let(:log) { StringIO.new }
    let(:logger) {
      logger = Logger.new(log)
      logger.formatter = lambda { |severity, datetime, progname, msg| msg }
      logger
    }
    let(:smtp) { Mailcrate.new(port) }
    let(:port) { 25552 }

    def mail
      count = 0
      until smtp.mails.any? || count > 4
        sleep 0.1
        count += 1
      end
      smtp.mails.last
    end

    before do
      TestMailer.logged_smtp_settings = {
        :port => port,
        :mail_file_logger => mail_file_logger,
        :logger => logger,
        :tls => false
      }
      smtp.start
    end

    after { smtp.stop }

    def without_file_logger
      original_logger = TestMailer.logged_smtp_settings[:mail_file_logger]
      TestMailer.logged_smtp_settings[:mail_file_logger] = nil
      yield
    ensure
      TestMailer.logged_smtp_settings[:mail_file_logger] = original_logger
    end

    it 'logs the mail to a file when the mail file logger is available' do
      TestMailer.welcome.deliver_now

      message_id = "12345@example.com"
      if Gem::Version.new(Mail::VERSION::STRING) >= Gem::Version.new("2.8.0")
        message_id = "<#{message_id}>"
      end

      assert_equal ["Date: Sat, 01 Jan 2000 00:00:00 +0000\r\nFrom: me@example.com\r\nTo: to@example.com\r\nMessage-ID: #{message_id}\r\nSubject: Welcome\r\nMime-Version: 1.0\r\nContent-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\nhello"], mail_file_logger.messages
    end

    it 'does not logs without file logger' do
      without_file_logger do
        TestMailer.welcome.deliver_now
        assert_equal [], mail_file_logger.messages
      end
    end

    it 'has the sender via the first from address' do
      TestMailer.welcome(:from => [ 'a@example.com', 'b@example.com' ]).deliver_now
      assert_equal '<a@example.com>', mail[:from]
    end

    it 'enables tls by default' do
      mailer = ActionMailer::LoggedSMTPDelivery.new(TestMailer.logged_smtp_settings.merge(:tls => nil))
      assert_equal true, mailer.settings[:tls]
    end

    it 'does not enable tls when disabled' do
      mailer = ActionMailer::LoggedSMTPDelivery.new(TestMailer.logged_smtp_settings)
      assert_equal false, mailer.settings[:tls]
    end

    it 'prefixes logs with the mail message id' do
      TestMailer.welcome.deliver_now
      assert_includes log.string, '12345@example.com stored at'
    end

    it 'does not log empty headers' do
      TestMailer.welcome.deliver_now
      refute_match(/^: \[/, log.string)
    end

    it 'logs headers when the log header is provided' do
      TestMailer.logged_smtp_settings[:log_header] = 'X-Delivery-Context'
      TestMailer.welcome('X-Delivery-Context' => 'hello-33').deliver_now
      assert_includes log.string, '12345@example.com X-Delivery-Context: [hello-33]'
    end

    it 'sends the mail' do
      TestMailer.welcome(
        :from => 'me@example.com',
        :to   => 'to@example.com',
        :cc   => 'cc@example.com',
        :body => 'hello'
      ).deliver_now

      message_id = "12345@example.com"
      if Gem::Version.new(Mail::VERSION::STRING) >= Gem::Version.new("2.8.0")
        message_id = "<#{message_id}>"
      end

      assert_equal "Date: Sat, 01 Jan 2000 00:00:00 +0000\nFrom: me@example.com\nTo: to@example.com\nCc: cc@example.com\nMessage-ID: #{message_id}\nSubject: Welcome\nMime-Version: 1.0\nContent-Type: text/plain;\n charset=UTF-8\nContent-Transfer-Encoding: 7bit\n\nhello", mail[:body]
      assert_equal "<me@example.com>", mail[:from]
      assert_equal ["<to@example.com>", "<cc@example.com>"], mail[:to_list]
    end

    it 'does not include BCC addresses in the message' do
      TestMailer.welcome(:bcc => 'bcc@example.com').deliver_now
      refute_includes mail[:body], "bcc@example.com"
    end

    it 'sends to bcc addresses' do
      TestMailer.welcome(:bcc => 'bcc@example.com').deliver_now
      assert_includes mail[:to_list], "<bcc@example.com>"
    end

    it 'contains the Net::SMTP::Response object in an instance variable' do
      mailer = ActionMailer::LoggedSMTPDelivery.new(TestMailer.logged_smtp_settings)
      mailer.send(:deliver!, TestMailer.welcome)

      _(mailer.response).must_be_kind_of Net::SMTP::Response
      _(mailer.response.status).must_equal '250'
    end

    describe 'delivery failures' do
      it 'logs any StandardError being thrown by the delivery method' do
        Net::SMTP.any_instance.stubs(:rcptto_list).raises(StandardError.new("kaboom"))
        assert_raises(StandardError) { TestMailer.welcome.deliver_now }
        assert_includes log.string, '12345@example.com exception #<StandardError: kaboom>'
        refute_includes log.string, 'done'
      end
    end
  end
end
