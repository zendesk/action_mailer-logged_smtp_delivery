# Logged SMTP Delivery

```Ruby
require 'action_mailer/logged_smtp_delivery'
config.action_mailer.logged_smtp_settings = {
  ... normal smtp settings ...,
  logger: Logger.new, # progress info
  mail_file_logger: Logger.new # log full encoded mails for storage
}


```


### Detailed log stream with message id prefix. Example:

```
<4e2b38d772949_b81ac212@localhost> stored at example/log/mails/outbound/2011-07-23/7_13462_2.eml
<4e2b38d772949_b81ac212@localhost> X-Delivery-Context: [users/1/welcome]
<4e2b38d772949_b81ac212@localhost> sender: support@support.localhost
<4e2b38d772949_b81ac212@localhost> destinations: support@system.example.com
<4e2b38d772949_b81ac212@localhost> done #<Net::SMTP::Response:0x10bbee680 @string="250 2.0.0 Ok: queued as 87BF716D7901\n", @status="250">
```

### Logs an identification header to quickly locate logs for a specific email/entity

```ruby
config.action_mailer.logged_smtp_settings[:log_header] = 'X-Delivery-Context'

class UsersMailer < ActionMailer::Base
  
  def welcome(user)
    headers['X-Delivery-Context'] = "users/#{user.id}/welcome"
    
    # ...
  end
end


UsersMailer.welcome(user).deliver
# ActionMailer::Base.logger -> 
# <4e2b38d772949_b81ac212@localhost> X-Delivery-Context: [users/1/welcome]
```
  
### Doesn't render BCC recipients

License: Apache V2

