require 'bundler/setup'
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib'))) # lib
require 'minitest/autorun'

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
