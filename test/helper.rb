require 'bundler/setup'
require 'action_mailer/logged_smtp_delivery'

require 'minitest/autorun'
require 'minitest/rg'
require 'logger'

I18n.enforce_available_locales = false

class MemoryLogger
  def log(message)
    messages << message
  end

  def messages
    @messages ||= []
  end

  def clear
    messages.clear
  end
end

class FakeSMTP
  attr_reader :address, :port, :credentials

  def self.deliveries
    @deliveries ||= []
  end

  def initialize(address, port)
    @address = address
    @port    = port
  end

  def start(*credentials)
    @credentials = credentials
    @started     = true

    yield(self)
  end

  def send_message(message, from, recipients)
    self.class.deliveries << [ message, from, recipients ]
  end

  def enable_starttls_auto
    @starttls = :auto
  end

  def starttls_auto?
    @starttls == :auto
  end

  def inspect
    "#<#{self.class} #{@address}:#{@port} started=#{@started}>"
  end
end
