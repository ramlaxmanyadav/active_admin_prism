# frozen_string_literal: true

module ActiveAdminPrism
  class Engine < ::Rails::Engine
    engine_name "active_admin_prism"

    # Must run before ActiveAdmin's own "active_admin.precompile" initializer,
    # which copies every registered stylesheet/javascript path into
    # app.config.assets.precompile. Registering here means a host app never
    # has to touch config.assets.precompile or add a manifest line itself.
    initializer "active_admin_prism.register_assets", before: "active_admin.precompile" do
      next unless defined?(ActiveAdmin)

      ActiveAdmin.application.register_stylesheet "active_admin_prism/prism.css", media: "all"
      ActiveAdmin.application.register_javascript "active_admin_prism/prism.js"
    end
  end
end
