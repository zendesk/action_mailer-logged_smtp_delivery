Gem::Specification.new do |gem|
  gem.authors       = ['Eric Chapweske']
  gem.description   = "ActionMailer SMTP delivery strategy with advanced logging and Bcc support"
  gem.summary       = "An ActionMailer delivery strategy"
  gem.homepage      = 'https://github.com/zendesk/action_mailer-logged_smtp_delivery'

  gem.files         = Dir.glob('lib/**/*') + ['README.md']

  gem.name          = 'action_mailer-logged_smtp_delivery'
  gem.version       = '2.0.2'
  gem.license       = "Apache V2"

  gem.add_runtime_dependency 'actionmailer', '>= 3.2.19', '< 4.3.0'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-rg'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bump'
  gem.add_development_dependency 'wwtd'
  gem.add_development_dependency 'mailcrate', '>= 0.0.2'
  gem.add_development_dependency 'byebug'
end
