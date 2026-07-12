# frozen_string_literal: true

module ActiveAdminPrism
  # A small, self-contained set of outline icons in the common
  # "24x24, currentColor stroke" line-icon style. Kept intentionally tiny —
  # just what the sidebar chrome needs — rather than bundling an icon font.
  module Icons
    ICONS = {
      dashboard: '<rect x="3" y="3" width="8" height="8" rx="1.5"/><rect x="13" y="3" width="8" height="5" rx="1.5"/>' \
                 '<rect x="13" y="10" width="8" height="11" rx="1.5"/><rect x="3" y="13" width="8" height="8" rx="1.5"/>',
      users: '<circle cx="9" cy="7" r="3.25"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/>' \
             '<path d="M16 4.3a3.25 3.25 0 0 1 0 6.4"/><path d="M15 14c2.8.4 5 2.8 5 6"/>',
      cart: '<circle cx="9" cy="20" r="1.5"/><circle cx="18" cy="20" r="1.5"/>' \
            '<path d="M2.5 3h2.4l1.2 12.1a2 2 0 0 0 2 1.9h9.4a2 2 0 0 0 2-1.7L21 7.5H6.4"/>',
      box: '<path d="M12 3 3 7.5 12 12l9-4.5Z"/><path d="M3 7.5v9L12 21l9-4.5v-9"/><path d="M12 12v9"/>',
      receipt: '<path d="M6 2h12v20l-3-2-3 2-3-2-3 2Z"/><path d="M9 8h6M9 12h6M9 16h3"/>',
      credit_card: '<rect x="2.5" y="5" width="19" height="14" rx="2"/><path d="M2.5 10h19"/><path d="M6 15h4"/>',
      message: '<path d="M4 4h16v12H8l-4 4Z"/>',
      settings: '<circle cx="12" cy="12" r="3.2"/>' \
                '<path d="M12 3.5v2.4M12 18.1v2.4M20.5 12h-2.4M5.9 12H3.5' \
                'M17.7 6.3l-1.7 1.7M8 16l-1.7 1.7M17.7 17.7 16 16M8 8 6.3 6.3"/>',
      chevron_down: '<polyline points="6 9 12 15 18 9"/>',
      check: '<polyline points="4 12 9 17 20 6"/>',
      x: '<path d="M5 5 19 19M19 5 5 19"/>',
      home: '<path d="M4 11 12 4l8 7"/><path d="M6 10v10h12V10"/><path d="M10 20v-6h4v6"/>',
      list: '<path d="M9 6h11M9 12h11M9 18h11"/><circle cx="4.5" cy="6" r="1.1"/>' \
            '<circle cx="4.5" cy="12" r="1.1"/><circle cx="4.5" cy="18" r="1.1"/>',
      folder: '<path d="M3 6.5a1 1 0 0 1 1-1h5l2 2.5h9a1 1 0 0 1 1 1V18a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1Z"/>',
      bell: '<path d="M6 10a6 6 0 1 1 12 0c0 4 1.2 5.5 1.2 5.5H4.8S6 14 6 10Z"/><path d="M10 19a2 2 0 0 0 4 0"/>',
      search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="M20 20l-4.7-4.7"/>',
      menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',
      logout: '<path d="M9 4H5a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h4"/><path d="M14 8l4 4-4 4"/><path d="M18 12H9"/>',
      eye: '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
      pencil: '<path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/><path d="M14.5 5.5l3 3"/>',
      trash: '<path d="M4 7h16"/><path d="M9 7V4h6v3"/><path d="M6 7l1 13h10l1-13"/>' \
             '<path d="M10 11v6M14 11v6"/>',
      filter: '<path d="M4 5h16l-6.5 7.5v6l-3 1.5v-7.5Z"/>',
      globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/>' \
             '<path d="M12 3c2.5 2.4 4 5.6 4 9s-1.5 6.6-4 9c-2.5-2.4-4-5.6-4-9s1.5-6.6 4-9Z"/>'
    }.freeze

    # Returns an inline <svg>...</svg> string for `name`, or nil if unknown.
    def self.svg(name, css_class: "prism-icon", size: 18)
      inner = ICONS[name.to_sym]
      return nil unless inner

      %(<svg class="#{css_class}" width="#{size}" height="#{size}" viewBox="0 0 24 24" ) +
        %(fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round" ) +
        %(stroke-linejoin="round" aria-hidden="true">#{inner}</svg>)
    end

    # The default sign-in page mark (see ActiveAdminPrism::Configuration
    # #login_logo) — a generic glass-prism-with-spectrum motif distinct from
    # the 24x24 line-icon set above (bigger, multi-color, animated via
    # scss-src/_login.scss's .prism-login-tri/.prism-login-beam classes).
    # Not tied to any brand — a host overriding #login_logo with their own
    # image_tag/svg is the norm for a real app.
    def self.login_mark(size: 64)
      <<~SVG
        <svg class="prism-login-mark" width="#{size}" height="#{size}" viewBox="0 0 100 100" aria-hidden="true">
          <polygon class="prism-login-tri" points="24,72 50,20 76,72" fill="currentColor" fill-opacity="0.08" stroke="currentColor" stroke-width="3"/>
          <line class="prism-login-beam" x1="2" y1="55" x2="38" y2="55" stroke="currentColor" stroke-width="4" stroke-linecap="round"/>
          <line class="prism-login-beam" x1="62" y1="46" x2="99" y2="30" stroke="#e53935" stroke-width="3" stroke-linecap="round"/>
          <line class="prism-login-beam" x1="62" y1="53" x2="99" y2="46" stroke="#fdd835" stroke-width="3" stroke-linecap="round"/>
          <line class="prism-login-beam" x1="62" y1="60" x2="99" y2="62" stroke="#1e88e5" stroke-width="3" stroke-linecap="round"/>
          <line class="prism-login-beam" x1="61" y1="67" x2="99" y2="78" stroke="#8e24aa" stroke-width="3" stroke-linecap="round"/>
        </svg>
      SVG
    end
  end

  # Exposed as a view helper so hosts can call `prism_icon(:cart)` directly
  # from Arbre blocks (app/admin/*.rb) or ERB views.
  module IconHelper
    def prism_icon(name, css_class: "prism-icon", size: 18)
      svg = ActiveAdminPrism::Icons.svg(name, css_class: css_class, size: size)
      svg&.html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end

ActiveAdmin::ViewHelpers.include(ActiveAdminPrism::IconHelper) if defined?(ActiveAdmin::ViewHelpers)
