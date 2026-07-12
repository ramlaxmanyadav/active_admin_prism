# frozen_string_literal: true

require_relative "lib/active_admin_prism/version"

Gem::Specification.new do |spec|
  spec.name        = "active_admin_prism"
  spec.version     = ActiveAdminPrism::VERSION
  spec.authors     = ["Ram Laxman Yadav"]
  spec.email       = ["yadavramlaxman@gmail.com"]

  spec.summary     = "Prism: a plug-and-play sidebar theme for ActiveAdmin"
  spec.description = "Prism is an ActiveAdmin theme that replaces the default top " \
                      "navigation with a collapsible left sidebar, restyles panels, " \
                      "tables and Formtastic forms into a modern card-based look, and " \
                      "ships as a zero-config Rails engine."
  spec.homepage     = "https://github.com/ramlaxmanyadav/active_admin_prism"
  spec.license      = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    Dir["app/**/*", "lib/**/*", "scss-src/**/*", "README.md", "INTEGRATION.md", "CHANGELOG.md", "LICENSE.txt"]
      .select { |f| File.file?(f) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activeadmin", ">= 3.0", "< 4"
  spec.add_dependency "railties", ">= 7.0", "< 9"

  spec.add_development_dependency "sassc", "~> 2.4"
end
