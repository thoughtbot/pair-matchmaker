source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5"

gem "rails", "~> 7.0.0"

gem "bootsnap", require: false
gem "bugsnag", "~> 6.24"
gem "pg"
gem "puma"

gem "sendgrid-actionmailer"
gem "slack-ruby-client", "~> 2.5.1"

# legacy - errors during RSpec if not there
gem "bigdecimal"
gem "drb"
gem "mutex_m"

# legacy - deprecation warnings during RSpec if not there
gem "benchmark"
gem "irb"
gem "ostruct"
gem "reline"

group :development, :test do
  gem "dotenv-rails"
  gem "pry-byebug"
  gem "standard"
end

group :development do
  gem "listen"
  gem "rack-mini-profiler"
end

group :test do
  gem "rspec"
  gem "rspec-rails"
end
