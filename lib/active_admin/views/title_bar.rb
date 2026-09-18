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
        end
      end
      private :build_titlebar_right
    end
  end
end
