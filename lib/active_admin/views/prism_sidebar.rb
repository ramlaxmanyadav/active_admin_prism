# frozen_string_literal: true

module ActiveAdmin
  module Views
    # Renders ActiveAdmin's existing Menu/MenuItem data (built by the
    # standard `menu do |m| ... end` DSL in app/admin/*.rb, untouched) as a
    # collapsible left sidebar instead of the default top nav bar.
    #
    # This is a drop-in replacement for ActiveAdmin::Views::Header: its
    # #build(namespace, menu) signature matches Header#build exactly, so it
    # can be swapped in via the supported extension point
    #
    #   ActiveAdmin::ViewFactory.register(header: ActiveAdmin::Views::PrismSidebar)
    #
    # (see ActiveAdminPrism.enable!) without touching Pages::Base or any
    # layout template.
    #
    # It does not reuse ActiveAdmin::Views::Menu/MenuItem's Arbre builder
    # verbs (`menu`/`menu_item`) because those are shared globally with
    # ActiveAdmin::Views::TabbedNavigation; walking the ActiveAdmin::Menu
    # data structure directly here keeps this theme fully isolated from
    # anything else that might rely on the stock nav rendering.
    class PrismSidebar < Component
      # Fallback icons for ActiveAdmin's own default utility-nav items
      # (id: "current_user" / id: "logout", added by
      # Namespace#build_default_utility_nav) when the host hasn't set one
      # explicitly via html_options: { icon: ... }.
      DEFAULT_ITEM_ICONS = { "current_user" => :users, "logout" => :logout }.freeze

      def build(namespace, menu)
        super(id: "header", class: "prism-sidebar")

        @namespace = namespace
        @menu = menu
        @utility_menu = namespace.fetch_menu(:utility_navigation)
        @current_tab = assigns[:current_tab]

        span(class: "prism-sidebar-mobile-toggle", data: { "prism-toggle-sidebar": true }) do
          text_node ActiveAdminPrism::Icons.svg(:menu, css_class: "prism-nav-icon").html_safe
        end

        div class: "prism-sidebar-inner" do
          div(class: "prism-sidebar-brand") { site_title @namespace }
          render_language_switcher if ActiveAdminPrism.configuration.language_switcher
          div(class: "prism-sidebar-scroll") do
            div "Pages", class: "prism-nav-section-label"
            render_menu @menu, class: "prism-nav"
          end
          if @utility_menu.items.any?
            div(class: "prism-sidebar-utility") do
              render_menu @utility_menu, class: "prism-nav prism-nav-utility"
            end
          end
          if ActiveAdminPrism.configuration.sidebar_footer
            div(class: "prism-sidebar-footer") { text_node footer_message }
          end
        end
      end

      private

      # Same content ActiveAdmin::Views::Footer renders into the page's own
      # #footer (custom config.footer text, or the default "Powered by
      # Active Admin X.Y.Z") — moved here instead, so it's pinned below the
      # nav/account area rather than trailing after the main content. The
      # original #footer is hidden via CSS (scss-src/_sidebar.scss) rather
      # than suppressed here, since Pages::Base#build_page always renders it
      # and overriding that too is more surface area than a display:none.
      def footer_message
        custom = @namespace.footer(self)
        return custom.html_safe if custom.present?

        helpers.t(
          "active_admin.powered_by",
          active_admin: helpers.link_to("Active Admin", "https://activeadmin.info"),
          version: ActiveAdmin::VERSION
        ).html_safe
      end

      # A small "Languages" dropdown near the top of the sidebar — see
      # ActiveAdminPrism::Configuration#language_switcher/#languages. Built
      # here directly (rather than via the `admin.build_menu
      # :utility_navigation do |menu| ... end` pattern ActiveAdmin apps
      # normally use for this by hand) so it needs no per-namespace
      # initializer code and stays in sync with runtime config changes —
      # every render reads the current config, the same as
      # sidebar_footer/collapsible_filters elsewhere in this gem.
      def render_language_switcher
        languages = ActiveAdminPrism.configuration.languages
        return if languages.blank?

        current = languages.find { |lang| lang[:locale].to_s == I18n.locale.to_s } || languages.first

        div(class: "prism-sidebar-lang") do
          span(class: "prism-lang-toggle", data: { "prism-toggle-lang": true }, "aria-expanded": "false") do
            text_node ActiveAdminPrism::Icons.svg(:globe, css_class: "prism-nav-icon").html_safe
            span(current[:label], class: "prism-lang-current")
            text_node chevron_svg
          end

          ul(class: "prism-lang-menu") do
            languages.each do |lang|
              classes = ["prism-lang-option"]
              classes << "active" if lang == current

              li do
                text_node helpers.link_to(lang[:label], language_url(lang), class: classes.join(" "))
              end
            end
          end
        end
      end

      # Each language entry's own :url (String/Proc/Symbol — same
      # nil/String/Proc/Symbol convention as config.login_logo etc.,
      # evaluated the same way item.url is above) wins when given, e.g. to
      # hit a remote endpoint that switches the locale server-side before
      # redirecting back:
      #
      #   { label: "English", locale: :en,
      #     url: -> { "https://example.com/set_locale?locale=en&return_to=#{request.path}" } }
      #
      # With no :url, this defaults to url_for(locale: lang[:locale]) —
      # appending "?locale=xx" to the *current* page, the same convention
      # ActiveAdmin apps already reach for by hand for this (see the
      # `url: proc { url_for(locale: l.locale) }` pattern in a hand-rolled
      # `admin.build_menu :utility_navigation` block).
      def language_url(lang)
        return evaluated(lang[:url]) if lang[:url]

        helpers.url_for(locale: lang[:locale])
      end

      def render_menu(menu_node, html_options = {})
        ul(html_options) do
          visible_items(menu_node).each { |item| render_item(item) }
        end
      end

      def visible_items(menu_node)
        menu_node.items
                 .select { |item| helpers.render_in_context(self, item.should_display) }
                 .sort_by { |item| [item.priority, evaluated(item.label).to_s] }
      end

      def render_item(item)
        label = evaluated(item.label)
        url = evaluated(item.url)
        has_children = item.items.any?
        active = item.current?(@current_tab)

        classes = ["prism-nav-item"]
        classes << "has-children" if has_children
        classes << "active" if active
        classes << "open" if has_children && active

        li(id: "prism_nav_#{item.id}", class: classes.join(" ")) do
          if has_children
            render_group_toggle(item, label)
            render_menu item, class: "prism-nav-submenu"
          else
            render_leaf(item, label, url)
          end
        end
      end

      def render_group_toggle(item, label)
        span(class: "prism-nav-group-toggle", data: { "prism-toggle": true }) do
          text_node icon_for(item)
          span(label, class: "prism-nav-label")
          text_node chevron_svg
        end
      end

      def render_leaf(item, label, url)
        link_options = item.html_options.except(:icon)
        link_options[:class] = ["prism-nav-link", link_options[:class]].compact.join(" ")

        if real_url?(url)
          text_node helpers.link_to(link_body(item, label), url, **link_options)
        else
          span(class: "prism-nav-link") { link_body(item, label) }
        end
      end

      def link_body(item, label)
        helpers.safe_join([icon_for(item), helpers.content_tag(:span, label, class: "prism-nav-label")])
      end

      # Always returns an html_safe string (possibly empty) — never escape-able
      # raw markup should cross a text_node/content_tag boundary unmarked.
      def icon_for(item)
        name = item.html_options[:icon] || DEFAULT_ITEM_ICONS[item.id]
        return "".html_safe unless name

        (ActiveAdminPrism::Icons.svg(name, css_class: "prism-nav-icon") || "").html_safe
      end

      def chevron_svg
        ActiveAdminPrism::Icons.svg(:chevron_down, css_class: "prism-chevron").html_safe
      end

      def evaluated(value)
        helpers.render_in_context(self, value)
      end

      def real_url?(url)
        url.present? && url != "#"
      end
    end
  end
end
