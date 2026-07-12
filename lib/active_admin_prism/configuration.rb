# frozen_string_literal: true

module ActiveAdminPrism
  # Per-feature toggles, so a host can turn off individual pieces of the
  # theme without forking it. Every flag defaults to the theme's normal,
  # fully-on behavior — an app that never touches this class gets exactly
  # what it got before this class existed.
  #
  #   ActiveAdminPrism.configure do |config|
  #     config.sidebar = false               # keep AA's stock top nav
  #     config.colorize_action_icons = false # plain text View/Edit/Delete
  #     config.flash_auto_dismiss_seconds = 8
  #   end
  #
  # `sidebar` and `colorize_action_icons` are pure server-side toggles
  # (they just change what Ruby renders). `sidebar_footer` is server-side
  # for whether the sidebar renders its own footer, plus a body class (like
  # `styled_confirms`/`collapsible_filters`) so the CSS knows whether to
  # keep hiding ActiveAdmin's original #footer. The flash_* flags are read
  # by the client-side prism.js via data attributes on ".flashes". See
  # lib/active_admin/views/flash_messages.rb for all of the body
  # class/data-attribute rendering.
  class Configuration
    # Whether ActiveAdminPrism.enable! swaps ActiveAdmin's top nav for
    # the Prism sidebar. Set to false to keep AA's stock header/TabbedNavigation
    # while still getting the rest of the theme (panels, tables, forms,
    # buttons, icons, flash/confirm styling) — useful for adopting Prism
    # incrementally, or reverting just the navigation without uninstalling
    # the gem.
    attr_accessor :sidebar

    # Whether index-table View/Edit/Delete links render as color-coded icon
    # buttons (see lib/active_admin/views/index_table_actions.rb). false
    # falls back to ActiveAdmin's plain text links.
    attr_accessor :colorize_action_icons

    # Whether row-level data-confirm links (View/Edit/Delete, or any other
    # rails-ujs confirm) are routed through ActiveAdmin's own styled jQuery
    # UI dialog instead of the native browser confirm(). Batch Actions
    # confirms are unaffected either way — they always use that dialog.
    attr_accessor :styled_confirms

    # Whether flash messages get a dismiss ("x") button.
    attr_accessor :flash_dismissible

    # Whether flash messages disappear on their own after
    # flash_auto_dismiss_seconds. Set to false to require a manual dismiss
    # (or, if flash_dismissible is also false, to leave them on screen
    # until the next page load, matching ActiveAdmin's own default).
    attr_accessor :flash_auto_dismiss
    attr_accessor :flash_auto_dismiss_seconds

    # How long the fade/slide-out transition takes (in milliseconds) when a
    # flash is dismissed — manually or automatically. Rendered as a data
    # attribute and read by prism.js, which sets it as an inline
    # transition-duration and uses the same value to time the element's
    # actual removal from the DOM, so the two always stay in sync.
    attr_accessor :flash_transition_ms

    # Whether ActiveAdmin's "Filters" sidebar panel starts collapsed to a
    # single icon button, expanding to the full form on click. false shows
    # it fully expanded at all times, matching ActiveAdmin's own default.
    attr_accessor :collapsible_filters

    # Whether "Powered by Active Admin" (or your own config.footer text)
    # moves from ActiveAdmin's page-level #footer into the sidebar, pinned
    # below the account/logout area. false leaves the original #footer
    # visible in its normal place instead (ActiveAdmin's own default).
    attr_accessor :sidebar_footer

    # Whether the sign-in page (Devise's sessions#new) gets Prism's
    # centered-card/brand-mark treatment. false renders ActiveAdmin's
    # original plain gradient-header login box instead (see
    # app/views/active_admin/devise/sessions/new.html.erb).
    attr_accessor :login_page

    # Customizes the mark shown above the sign-in form. One of:
    #   nil     - Prism's own built-in mark (default)
    #   String  - raw HTML, e.g. a pre-rendered image_tag/svg — used as-is,
    #             so make sure it's from a trusted source (html_safe)
    #   Proc    - instance_exec'd in the view's own context (so helpers like
    #             `image_tag`/`prism_icon` are available), e.g.:
    #               config.login_logo = -> { image_tag "logo.svg", height: 40 }
    #   Symbol  - a method name called on the view context
    # Same nil/String/Proc/Symbol convention ActiveAdmin itself uses for
    # config.footer / config.site_title_image.
    attr_accessor :login_logo

    # The name/title shown on the sign-in page. nil (default) falls back to
    # ActiveAdmin's own `config.site_title`. Accepts a String, Proc, or
    # Symbol — same convention as login_logo.
    attr_accessor :login_app_name

    # The line of text shown under the title on the sign-in page. nil means
    # no tagline is rendered. Accepts a String, Proc, or Symbol — same
    # convention as login_logo.
    attr_accessor :login_tagline

    # Whether a "Languages" dropdown renders near the top of the sidebar
    # (below the brand, above the Pages nav), letting a visitor switch
    # `locale` without your own `admin.build_menu :utility_navigation` code
    # — see lib/active_admin/views/prism_sidebar.rb for the actual link
    # (`url_for(locale: ...)`, the same query-param convention ActiveAdmin
    # apps already use for this by hand). false renders no dropdown at all.
    attr_accessor :language_switcher

    # The options the dropdown lists — an array of
    # `{ label:, locale:, url: }` hashes (`url:` is optional). Defaults to
    # 3 common ones; replace the whole array to add, remove, or reorder
    # languages:
    #
    #   ActiveAdminPrism.configure do |config|
    #     config.languages = [
    #       { label: "English", locale: :en },
    #       { label: "Deutsch", locale: :de },
    #       { label: "日本語", locale: :ja,
    #         url: -> { "https://example.com/set_locale?locale=ja&return_to=#{request.path}" } }
    #     ]
    #   end
    #
    # `url:` accepts a String, Proc, or Symbol (same nil/String/Proc/Symbol
    # convention as login_logo, evaluated the same way an
    # ActiveAdmin::MenuItem's own `url:` proc is — bare `url_for`/`request`/
    # any other view helper is available inside it, same as in the
    # `url: proc { url_for(locale: l.locale) }` pattern an ActiveAdmin app
    # already reaches for by hand for this). With no `url:`, this defaults
    # to `url_for(locale: lang[:locale])` — appending `?locale=xx` to the
    # *current* page. Use `url:` when switching locale needs to hit a
    # remote/dedicated endpoint (e.g. one that sets a cookie or session key
    # and redirects back) rather than just changing a query param on the
    # current URL.
    #
    # This only renders the switcher itself — actually honoring the
    # `locale` param (e.g. a `before_action { I18n.locale = params[:locale]
    # || I18n.default_locale }`) is your own app's responsibility, the same
    # as it would be if you'd wired up the utility_navigation menu by hand.
    attr_accessor :languages

    def initialize
      @sidebar = true
      @colorize_action_icons = true
      @styled_confirms = true
      @flash_dismissible = true
      @flash_auto_dismiss = true
      @flash_auto_dismiss_seconds = 5
      @flash_transition_ms = 320
      @collapsible_filters = true
      @sidebar_footer = true
      @login_page = true
      @login_logo = nil
      @login_app_name = nil
      @login_tagline = "Sign in to your admin dashboard"
      @language_switcher = true
      @languages = [
        { label: "English", locale: :en },
        { label: "Español", locale: :es },
        { label: "Français", locale: :fr }
      ]
    end
  end

  class << self
    # @return [ActiveAdminPrism::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # ActiveAdminPrism.configure do |config|
    #   config.sidebar = false
    # end
    def configure
      yield(configuration)
    end

    # Mainly for test suites: resets every flag back to its default.
    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
