ENV["RAILS_ENV"] ||= "test"

if ENV.fetch("COVERAGE", false)
  require "simplecov"
  SimpleCov.start "rails" do
    enable_coverage :branch
  end
end

require "spec_helper"
require_relative "../config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Slack::ClientWrapper.disable!

Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |file| require file }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include DatabaseHelpers
  config.include MatchmakingHelpers, type: :matchmaking
end
