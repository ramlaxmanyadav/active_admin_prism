# frozen_string_literal: true

module ActiveAdmin
  module Views
    class IndexAsTable
      class IndexTableFor
        # ActiveAdmin's default View/Edit/Delete row links (built by
        # IndexTableFor#defaults) already carry distinct classes —
        # "view_link", "edit_link", "delete_link" — specifically so themes
        # can hook into them. This swaps their text label for an icon +
        # a visually-hidden label (kept for screen readers/tooltips),
        # without touching the url/method/data-confirm behavior at all.
        # Any other custom `item(...)` call (e.g. from a host's own
        # `actions do |resource| item "Preview", ... end` block) is
        # untouched, since it won't carry one of these classes.
        class TableActions
          ACTION_ICONS = {
            "view_link" => :eye,
            "edit_link" => :pencil,
            "delete_link" => :trash
          }.freeze

          def item(*args, **kwargs)
            unless ActiveAdminPrism.configuration.colorize_action_icons
              return text_node helpers.link_to(*args, **kwargs)
            end

            label = args[0]
            url = args[1]
            icon_name = ACTION_ICONS.values_at(*kwargs[:class].to_s.split).compact.first

            unless icon_name && (icon = ActiveAdminPrism::Icons.svg(icon_name, css_class: "prism-action-icon"))
              return text_node helpers.link_to(*args, **kwargs)
            end

            content = helpers.safe_join([
              icon.html_safe,
              helpers.content_tag(:span, label, class: "prism-visually-hidden")
            ])
            text_node helpers.link_to(content, url, **kwargs)
          end
        end
      end
    end
  end
end
