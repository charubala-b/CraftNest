# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'  # Optional: ignore specs themselves
end

require 'faker'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

# Checks for pending migrations and applies them before tests are run.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# ✅ Inline helper to parse JSON response
module JsonHelpers
  def json_response
    JSON.parse(response.body)
  end
end

# ✅ Inline helper to print response for debugging (optional)
module DebugHelpers
  def print_debug_response
    puts "Status: #{response.status}"
    puts "Body: #{response.body}"
  end
end

RSpec.configure do |config|
  config.before(:each, type: :request) do
    Rails.logger.debug "Token expired?: #{Doorkeeper::AccessToken.last&.expired?}"
    Rails.logger.debug "Token revoked?: #{Doorkeeper::AccessToken.last&.revoked_at.present?}"
  end
  config.before(:suite) do
    Time.zone = 'Asia/Kolkata' # or your local timezone
  end

  # ✅ FactoryBot methods like `create`, `build`
  config.include FactoryBot::Syntax::Methods

  # ✅ Include helpers for request specs

  # ✅ Use transactional DB between examples
  config.use_transactional_fixtures = true

  # ✅ Auto-detect spec type by file location (e.g., models, requests)
  config.infer_spec_type_from_file_location!

  # ✅ Clean backtrace output
  config.filter_rails_from_backtrace!

  # ✅ Fixtures directory (if used)
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
end
