source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.8"

gem "rails", "~> 7.0.0"
gem "puma"
gem "slack-ruby-client"
gem "bootsnap", require: false
gem "pg"
gem "bugsnag", "~> 6.24"
gem "sendgrid-actionmailer"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "standard"
end

group :development do
  gem "rack-mini-profiler"
  gem "listen"
end

group :test do
  gem "rspec"
  gem "rspec-rails"
end
