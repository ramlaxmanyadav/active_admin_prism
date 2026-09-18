# frozen_string_literal: true

module ActiveAdmin
  module Views
    # Reopens ActiveAdmin::Views::ActionItems purely to mark the
    # auto-registered "New <Resource>" action item with its own class —
    # ActiveAdmin::Resource::ActionItems#add_default_new_action_item names
    # it :new internally, but that name never reaches the rendered
    # `span.action_item` itself (ActionItem#html_class only ever emits
    # "action_item" plus a host's own optional :class, nothing derived
    # from the name), so there'd otherwise be no way for CSS/JS to tell it
    # apart from any other action_item at all.
    #
    # js-src/prism.js's consolidated-action-items dropdown reads this to
    # always exclude the New-resource button from consolidation, leaving
    # it inline in its original spot — it's the single most-used action on
    # an index page, unlike the bulk-action/CSV-upload links this feature
    # was actually built to tidy away, so sweeping it into a dropdown too
    # would bury the one button visitors reach for constantly.
    class ActionItems
      def build(action_items)
        action_items.each do |action_item|
          classes = [action_item.html_class]
          classes << "prism-action-item-new" if action_item.name == :new
          span class: classes.join(" ") do
            instance_exec(&action_item.block)
          end
        end
      end
    end
  end
end
