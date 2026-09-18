# frozen_string_literal: true

module ActiveAdmin
  module Views
    # Reopens ActiveAdmin::Views::TitleBar purely to render
    # ActiveAdminPrism::Configuration#action_items_dropdown_threshold as a
    # data attribute on "#titlebar_right" — js-src/prism.js reads it at
    # runtime to decide whether the action_item buttons it finds inside
    # need consolidating into a dropdown (see that file, and
    # scss-src/_buttons.scss for the dropdown's own styling). Nothing else
    # about title bar rendering changes; this can't be done in CSS alone
    # since deciding whether to consolidate depends on *counting* how many
    # action_items actually rendered, not just their presence.
    class TitleBar
      def build_titlebar_right
        config = ActiveAdminPrism.configuration
        data = {}
        data[:"prism-action-items-threshold"] = config.action_items_dropdown_threshold if config.action_items_dropdown

        div id: "titlebar_right", data: data do
          build_action_items
          # A page with many action_items renders every one of them
          # inline first (this is still plain ActiveAdmin markup, no JS
          # involved yet) — consolidating them into the "Actions" dropdown
          # only happens once js-src/prism.js's own DOMContentLoaded
          # handler runs, which on a slow connection can lag well behind
          # this markup already having been parsed and painted, flashing
          # the full unstyled wall of buttons first. A classic script tag
          # placed immediately after them executes synchronously, before
          # the parser (and so the renderer) moves on to anything else on
          # the page — flipping a class here, right as this element is
          # being parsed, hides them via CSS
          # (scss-src/_buttons.scss's "#titlebar_right.prism-action-items-pending")
          # well before that lag would otherwise show anything. If JS is
          # disabled entirely, this inline script itself never runs
          # either, so the class is never added and the original inline
          # buttons stay fully visible and functional — same graceful
          # fallback the dropdown feature already has. prism.js's own
          # action-items handler is what removes this class again, right
          # before either moving them into its hidden holding area (the
          # normal consolidated case) or, below its own threshold,
          # leaving them exactly as rendered here.
          text_node '<script>document.currentScript.parentElement.classList.add("prism-action-items-pending")</script>'.html_safe if config.action_items_dropdown # rubocop:disable Rails/OutputSafety
        end
      end
      private :build_titlebar_right
    end
  end
end
