For bug reports, open an [issue](https://github.com/zendesk/action_mailer-logged_smtp_delivery/issues) on GitHub.

## Getting Started

 1. Install dependencies with `bundle install`
 1. Run tests with `rake test`

## Releasing

Releases are published by the `zendesk` account using a GitHub action.
Once your pull request is merged, an appropriate `rake bump:{major,minor,patch}` will update the version and push a commit.
After the bump, `./script/bundle update --conservative` and then commit the resulting locked `gemfiles`.
Running `rake release` will then push a tag, and attempt to publish to RubyGems.
Once the tag has been pushed, the `rake release` can be canceled.
Then the GitHub action, once approved by a Zendeskian, will publish to [RubyGems.org](https://rubygems.org/gems/action_mailer-logged_smtp_delivery).
