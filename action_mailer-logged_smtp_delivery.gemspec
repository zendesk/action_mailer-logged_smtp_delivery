Gem::Specification.new do |gem|
  gem.authors       = ['Eric Chapweske']
  gem.description   = "ActionMailer SMTP delivery strategy with advanced logging and Bcc support"
  gem.summary       = "An ActionMailer delivery strategy"
  gem.homepage      = 'https://github.com/grosser/action_mailer-logged_smtp_delivery'

  gem.files         = Dir.glob('lib/**/*') + ['README.md']

  gem.name          = 'action_mailer-logged_smtp_delivery'
  gem.version       = '1.1.0'
  gem.license       = "Apache V2"

  gem.add_development_dependency 'actionmailer', '~> 3.2.19'
  gem.add_development_dependency 'minitest', '~> 4.7.5'
  gem.add_development_dependency 'minitest-rg'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bump'
end
