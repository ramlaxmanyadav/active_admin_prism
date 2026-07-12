require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false

  config.public_file_server.enabled = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = :none
  config.action_controller.allow_forgery_protection = false

  config.active_support.deprecation = :stderr

  config.secret_key_base = "test" * 20

  config.assets.compile = true
  config.assets.check_precompiled_asset = false
end
