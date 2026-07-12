# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Test-suite-only dependencies (the gem's own runtime deps — activeadmin,
# railties — are declared in the gemspec). Pinned to the same Rails/AA
# combination this gem has been developed and manually verified against
# (see the sibling demo app), to avoid introducing untested compatibility
# surface here.
gem "rails", "~> 7.1.6"
gem "sqlite3"
gem "puma"
gem "sprockets-rails"
gem "sassc-rails"
gem "devise"
gem "rspec-rails"
