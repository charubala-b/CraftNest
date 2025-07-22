require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
end

require 'faker'
require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# === Helper Modules ===
module JsonHelpers
  def json_response
    JSON.parse(response.body)
  end
end

module DebugHelpers
  def print_debug_response
    puts "Status: #{response.status}"
    puts "Body: #{response.body}"
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Time.zone = 'Asia/Kolkata'
  end

  config.before(:each, type: :request) do
    if ENV['DEBUG'] == 'true'
      token = Doorkeeper::AccessToken.last
      Rails.logger.debug "Token expired?: #{token&.expired?}"
      Rails.logger.debug "Token revoked?: #{token&.revoked_at.present?}"
      Rails.logger.debug "Token scopes: #{token&.scopes}"
      Rails.logger.debug "Token acceptable? (read): #{token&.acceptable?(:read)}"
    end
  end

  config.include FactoryBot::Syntax::Methods
  config.include JsonHelpers, type: :request
  config.include DebugHelpers, type: :request

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]
end
