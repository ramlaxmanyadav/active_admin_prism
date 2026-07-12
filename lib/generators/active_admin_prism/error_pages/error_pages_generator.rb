# frozen_string_literal: true

module ActiveAdminPrism
  module Generators
    # rails g active_admin_prism:error_pages
    #
    # Copies Prism-styled public/404.html and public/500.html into this
    # app. Unlike the rest of the theme, static exception pages
    # (config.exceptions_app's default, ActionDispatch::PublicExceptions)
    # are read straight off disk from Rails.public_path, completely
    # outside the asset pipeline and Rails' view-resolution/engine-view-path
    # mechanism — there's no way for a gem to "register" or override them
    # the way ActiveAdminPrism::Engine registers stylesheets/
    # javascripts, or the way this gem's own sign-in page view shadows
    # ActiveAdmin's. Copying them into the host app (the same way `rails
    # new` scaffolds its own default public/404.html) is the only option.
    #
    # Not run automatically by the `install` generator, unlike everything
    # else in this theme: a host's public/404.html and public/500.html are
    # typically already customized/committed, and silently overwriting them
    # (or ambushing an unrelated `install` run with copy_file's overwrite
    # prompt) would be surprising. This is an explicit, separate opt-in.
    #
    # These are plain static HTML/CSS, not ERB — no Ruby config, no
    # ActiveAdminPrism::Configuration flag, and no @import of
    # prism.css (impossible for a file with no Rails request cycle behind
    # it). Edit the copied files directly for any further changes; a
    # future gem upgrade never touches them again once copied.
    class ErrorPagesGenerator < ::Rails::Generators::Base
      desc "Copies Prism-styled public/404.html and public/500.html into this app"

      source_root File.expand_path("templates", __dir__)

      def copy_error_pages
        copy_file "404.html", "public/404.html"
        copy_file "500.html", "public/500.html"
      end

      def show_notes
        say_status :note,
                   "these are plain static files now living in public/ — edit them " \
                   "directly for further changes, and re-run this generator " \
                   "(it will prompt before overwriting) to pick up a newer version " \
                   "of the gem's default templates",
                   :yellow
      end
    end
  end
end
