ENV["RAILS_ENV"] ||= "test"

require_relative "spec_helper"
require_relative "dummy/config/environment"

require "rspec/rails"

# No committed schema.rb for this dummy app (raw migrations only, kept
# minimal on purpose) — run them directly against the sqlite test db
# instead of ActiveRecord::Migration.maintain_test_schema!, which expects
# a schema file to load. Migrations are idempotent (ActiveRecord tracks
# schema_migrations), so this is safe to run on every suite invocation.
ActiveRecord::Migration.verbose = false
ActiveRecord::MigrationContext.new(Rails.root.join("db/migrate")).migrate

RSpec.configure do |config|
  config.fixture_paths = [File.join(__dir__, "fixtures")]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include Devise::Test::IntegrationHelpers, type: :request

  config.before do
    ActiveAdminPrism.reset_configuration!
  end
end
