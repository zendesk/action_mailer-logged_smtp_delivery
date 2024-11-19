Gem::Specification.new do |gem|
  gem.authors       = ['Eric Chapweske']
  gem.description   = "ActionMailer SMTP delivery strategy with advanced logging and Bcc support"
  gem.summary       = "An ActionMailer delivery strategy"
  gem.homepage      = 'https://github.com/zendesk/action_mailer-logged_smtp_delivery'

  gem.files         = Dir.glob('lib/**/*') + ['README.md']

  gem.name          = 'action_mailer-logged_smtp_delivery'
  gem.version       = '2.4.0'
  gem.license       = "Apache V2"

  gem.required_ruby_version = ">= 3.1"

  gem.add_runtime_dependency 'actionmailer', '>= 6.1'
  gem.add_runtime_dependency 'globalid', '>= 1.0.1'
  gem.add_runtime_dependency 'loofah', '>= 2.19.1'
  gem.add_runtime_dependency 'mail'
  gem.add_runtime_dependency 'net-smtp'
  gem.add_runtime_dependency 'nokogiri', '>= 1.13.9'
  gem.add_runtime_dependency 'rack', '>= 2.2.6.4'
  gem.add_runtime_dependency 'rails-html-sanitizer', '>= 1.4.4'

  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'byebug'
  gem.add_development_dependency 'mailcrate'
  gem.add_development_dependency 'minitest-rg'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'rake'
end
