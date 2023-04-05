require 'bundler/setup'
require 'action_mailer/logged_smtp_delivery'

require 'minitest/autorun'
require 'minitest/rg'
require 'mocha/minitest'
require 'logger'
require 'mailcrate'

I18n.enforce_available_locales = false

Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

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
