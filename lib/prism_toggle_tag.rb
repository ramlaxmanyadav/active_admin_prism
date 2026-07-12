# frozen_string_literal: true

module ActiveAdminPrism
  # A read-only toggle-switch visual for boolean values on index/show pages
  # — the same look as the opt-in `f.input :x, as: :prism_toggle` form
  # input, but for display rather than editing. ActiveAdmin's own default
  # (status_tag "Yes"/"No") is untouched; this is an explicit opt-in helper
  # a host calls from its own `column`/`row` block, e.g.:
  #
  #   index do
  #     column :active do |product|
  #       prism_toggle_tag product.active
  #     end
  #   end
  #
  #   show do
  #     attributes_table do
  #       row :active do |product|
  #         prism_toggle_tag product.active
  #       end
  #     end
  #   end
  module ToggleTagHelper
    def prism_toggle_tag(value, on_label: "Yes", off_label: "No")
      label = value ? on_label : off_label

      content_tag(:span, class: "prism-toggle-tag #{value ? 'on' : 'off'}",
                          role: "img", "aria-label": label, title: label) do
        content_tag(:span, "", class: "prism-toggle-track", "aria-hidden": "true")
      end
    end
  end
end

ActiveAdmin::ViewHelpers.include(ActiveAdminPrism::ToggleTagHelper) if defined?(ActiveAdmin::ViewHelpers)
