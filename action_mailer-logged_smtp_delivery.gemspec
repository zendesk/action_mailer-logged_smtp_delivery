Gem::Specification.new do |gem|
  gem.authors       = ['Eric Chapweske']
  gem.description   = "ActionMailer SMTP delivery strategy with advanced logging and Bcc support"
  gem.summary       = "An ActionMailer delivery strategy"
  gem.homepage      = 'https://github.com/zendesk/action_mailer-logged_smtp_delivery'

  gem.files         = Dir.glob('lib/**/*') + ['README.md']

  gem.name          = 'action_mailer-logged_smtp_delivery'
  gem.version       = '2.2.4'
  gem.license       = "Apache V2"

  gem.required_ruby_version = ">= 2.7"

  gem.add_runtime_dependency 'actionmailer', '>= 6.0'
  gem.add_runtime_dependency 'net-smtp'
  gem.add_runtime_dependency 'mail', '>= 2.7.1', '<= 2.8.0' # FIXME: v2.8.0 changes Message-ID and adds ASCII-8BIT encoding:
  #
  # 1) Failure: delivery#test_0009_sends the mail [/home/runner/work/action_mailer-logged_smtp_delivery/action_mailer-logged_smtp_delivery/test/logged_smtp_delivery_test.rb:109]:
  # --- expected
  # +++ actual
  # +# encoding: ASCII-8BIT
  # +#    valid: true
  # -Message-ID: 12345@example.com
  # +Message-ID: <12345@example.com>
  #
  # 2) Failure: delivery#test_0001_logs the mail to a file when the mail file logger is available [/home/runner/work//3action_mailer-logged_smtp_delivery/action_mailer-logged_smtp_delivery/test/logged_smtp_delivery_test.rb:60]:
  # --- expected
  # +++ actual
  # -Message-ID: 12345@example.com\r
  # +Message-ID: <12345@example.com>\r
  #

  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'mailcrate'
  gem.add_development_dependency 'minitest-rg'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'rake'
end
