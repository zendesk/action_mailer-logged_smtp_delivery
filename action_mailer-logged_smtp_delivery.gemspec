# encoding: utf-8

Gem::Specification.new do |gem|
  gem.authors       = ['Eric Chapweske']
  gem.description   = "ActionMailer SMTP delivery strategy with advanced logging and Bcc support"
  gem.summary       = "An ActionMailer delivery strategy"
  gem.homepage      = 'https://github.com/eac/action_mailer-logged_smtp_delivery'

  gem.files         = Dir.glob('{lib,test}/**/*') + ['README.md', 'CONTRIBUTING.md']
  gem.test_files    = gem.files.grep(/test\//)
  gem.require_paths = ['lib']

  gem.name          = 'action_mailer-logged_smtp_delivery'
  gem.require_paths = ['lib']
  gem.version       = '1.0.0'

  gem.add_development_dependency 'actionmailer', '2.3.16'
  gem.add_development_dependency 'minitest'
end
