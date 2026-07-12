# frozen_string_literal: true

module ActiveAdminPrism
  # Resolves ActiveAdminPrism::Configuration#login_logo/#login_app_name/
  # #login_tagline for app/views/active_admin/devise/sessions/new.html.erb.
  #
  # Mixed into ActiveAdmin::ViewHelpers (see the bottom of this file), which
  # ActiveAdmin::Devise::Controller already adds as a controller `helper` —
  # so these methods, and `render_in_context`/`active_admin_application`
  # (both part of ActiveAdmin::ViewHelpers already), are directly callable
  # from the plain-ERB devise views with no extra wiring.
  module LoginHelper
    def prism_login_logo_html
      custom = render_in_context(self, ActiveAdminPrism.configuration.login_logo)
      return custom.to_s.html_safe if custom.present? # rubocop:disable Rails/OutputSafety

      ActiveAdminPrism::Icons.login_mark.html_safe # rubocop:disable Rails/OutputSafety
    end

    def prism_login_app_name
      custom = render_in_context(self, ActiveAdminPrism.configuration.login_app_name)
      custom.presence || active_admin_application.site_title(self)
    end

    def prism_login_tagline
      render_in_context(self, ActiveAdminPrism.configuration.login_tagline)
    end
  end
end

ActiveAdmin::ViewHelpers.include(ActiveAdminPrism::LoginHelper) if defined?(ActiveAdmin::ViewHelpers)
