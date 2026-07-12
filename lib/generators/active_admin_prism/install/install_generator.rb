# frozen_string_literal: true

module ActiveAdminPrism
  module Generators
    # rails g active_admin_prism:install
    #
    # The only manual install step this theme needs: enabling the sidebar.
    # Stylesheet/javascript registration is automatic (see
    # ActiveAdminPrism::Engine) — nothing to add to an asset manifest.
    class InstallGenerator < ::Rails::Generators::Base
      desc "Enables the Prism sidebar and Sass palette overrides"

      ENABLE_LINE = "ActiveAdminPrism.enable!\n"
      INITIALIZER_PATH = "config/initializers/active_admin.rb"

      STYLESHEET_PATH = "app/assets/stylesheets/active_admin.scss"
      VARIABLE_IMPORT_LINE = '@import "active_admin_prism/variable_overrides";'
      MIXINS_IMPORT_PATTERN = /@import\s+["']active_admin\/mixins["'];?/.freeze

      def enable_active_admin_prism
        unless File.exist?(File.join(destination_root, INITIALIZER_PATH))
          say_status :error,
                     "#{INITIALIZER_PATH} not found — run `rails g active_admin:install` first",
                     :red
          return
        end

        if File.read(File.join(destination_root, INITIALIZER_PATH)).include?("ActiveAdminPrism.enable!")
          say_status :identical, INITIALIZER_PATH, :blue
        else
          append_to_file INITIALIZER_PATH, "\n#{ENABLE_LINE}"
        end
      end

      # Injects the palette override import just before
      # `@import "active_admin/mixins"` — order matters, since every
      # variable in variable_overrides.scss is `!default` and only wins if
      # it runs first. See that file for what it overrides and why.
      def override_active_admin_sass_variables
        full_path = File.join(destination_root, STYLESHEET_PATH)

        unless File.exist?(full_path)
          say_status :skip,
                     "#{STYLESHEET_PATH} not found — if you add one later, put " \
                     "`#{VARIABLE_IMPORT_LINE}` before your \"active_admin/mixins\" import",
                     :yellow
          return
        end

        contents = File.read(full_path)

        if contents.include?("active_admin_prism/variable_overrides")
          say_status :identical, STYLESHEET_PATH, :blue
          return
        end

        unless contents.match?(MIXINS_IMPORT_PATTERN)
          say_status :skip,
                     "couldn't find an `@import \"active_admin/mixins\";` line in #{STYLESHEET_PATH} — " \
                     "add `#{VARIABLE_IMPORT_LINE}` above it yourself",
                     :yellow
          return
        end

        inject_into_file STYLESHEET_PATH, "#{VARIABLE_IMPORT_LINE}\n", before: MIXINS_IMPORT_PATTERN
      end
    end
  end
end
