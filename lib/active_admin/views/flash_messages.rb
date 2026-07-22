# frozen_string_literal: true

module ActiveAdmin
  module Views
    module Pages
      # Reopens ActiveAdmin::Views::Pages::Base to add a dismiss ("x")
      # button to each flash message, and to render the configured
      # auto-dismiss delay as a data attribute prism.js reads at runtime
      # (see ActiveAdminPrism::Configuration#flash_dismissible /
      # #flash_auto_dismiss / #flash_auto_dismiss_seconds).
      #
      # The stock #build_flash_messages just renders
      # `div message, class: "flash flash_#{type}"` — no room for a button.
      # When flash_dismissible is false, that exact stock markup is what
      # this renders; only when it's true (the default) does the message
      # get wrapped with a dismiss button alongside it.
      #
      # Auto-dismiss timing and the click handler for the dismiss button
      # both live in active_admin_prism/prism.js (CSS alone can't
      # remove an element from the DOM or run a timer).
      class Base
        def build_flash_messages
          config = ActiveAdminPrism.configuration
          flashes_data = { "prism-transition-ms": config.flash_transition_ms.to_i }
          if config.flash_auto_dismiss
            flashes_data[:"prism-auto-dismiss-ms"] = (config.flash_auto_dismiss_seconds.to_f * 1000).round
          end

          div class: "flashes", data: flashes_data do
            flash_messages.each do |type, messages|
              [*messages].each do |message|
                if config.flash_dismissible
                  div class: "flash flash_#{type}" do
                    span message, class: "prism-flash-message"
                    button class: "prism-flash-dismiss", type: "button",
                           "aria-label": "Dismiss", data: { "prism-flash-dismiss": true } do
                      text_node ActiveAdminPrism::Icons.svg(:x, css_class: "prism-flash-dismiss-icon", size: 14).html_safe
                    end
                  end
                else
                  div message, class: "flash flash_#{type}"
                end
              end
            end
          end
        end

        # Read by prism.js / scss-src's CSS to decide whether to route
        # data-confirm links through the styled dialog, whether the Filters
        # sidebar panel collapses to an icon, whether ActiveAdmin's
        # original #footer should stay hidden, and whether every plain
        # <select> should be auto-enhanced into Select2 (see
        # ActiveAdminPrism::Configuration #styled_confirms /
        # #collapsible_filters / #sidebar_footer / #select2).
        #
        # Can't call `super` here — #body_classes is defined directly on
        # this same class (not a superclass), so reopening and redefining
        # it replaces that definition outright; there's no ancestor
        # implementation left for `super` to reach; (Arbre::Element#method_missing
        # would silently redirect it right back to this same method,
        # recursing forever). The body has to be copied instead.
        def body_classes
          config = ActiveAdminPrism.configuration
          classes = Arbre::HTML::ClassList.new [
            params[:action],
            params[:controller].tr("/", "_"),
            "active_admin", "logged_in",
            active_admin_namespace.name.to_s + "_namespace"
          ]
          classes << "prism-styled-confirms-disabled" unless config.styled_confirms
          classes << "prism-filters-collapsible-disabled" unless config.collapsible_filters
          classes << "prism-sidebar-footer-disabled" unless config.sidebar_footer
          classes << "prism-select2-enabled" if config.select2
          classes
        end
      end
    end
  end
end
