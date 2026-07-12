require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "activeadmin"
require "active_admin_prism"

module Dummy
  class Application < Rails::Application
    # Rails::Application's default root-detection walks UP from this
    # file's directory looking for the first Gemfile/config.ru it finds —
    # since this dummy app has no Gemfile of its own (it shares the gem's
    # own outer Gemfile, on purpose, so Bundler resolves one dependency
    # set), that walk would otherwise keep going past spec/dummy and land
    # on the gem's own root Gemfile, misidentifying the whole gem
    # repository as Rails.root. Setting this explicitly avoids that.
    config.root = File.expand_path("..", __dir__)

    config.load_defaults 7.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators.system_tests = nil
    config.eager_load = false
    config.hosts.clear
  end
end
