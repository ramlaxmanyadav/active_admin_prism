# frozen_string_literal: true

module Formtastic
  module Inputs
    # An opt-in boolean input rendered as an iOS-style switch instead of a
    # checkbox, matching the "Toggle switches" section of the Prism theme.
    #
    #   f.input :active, as: :prism_toggle
    #
    # Reuses BooleanInput's hidden-field/checked-value/name logic verbatim —
    # only the wrapping markup changes, so submitted params are identical to
    # a normal `as: :boolean` input.
    class PrismToggleInput < Formtastic::Inputs::BooleanInput
      def label_with_nested_checkbox
        builder.label(
          method,
          check_box_html + template.content_tag(:span, "", class: "prism-toggle-track") + label_text,
          label_html_options
        )
      end

      def input_html_options
        super.merge(class: [super[:class], "prism-toggle-input"].reject(&:blank?).join(" "))
      end

      def label_html_options
        super.merge(class: [super[:class], "prism-toggle"].reject(&:blank?).join(" "))
      end
    end
  end
end
