# frozen_string_literal: true

module ActiveAdmin
  module Views
    # Reopens ActiveAdmin::Views::SidebarSection (used for every sidebar
    # section — "Filters", "Search Status", and any custom
    # `sidebar "Title" do ... end` block a host app registers) to collapse
    # *every* section to a single icon button by default, expanding to the
    # full panel on click — not just the Filters section, which is all this
    # used to do.
    #
    # Why generalize this: the #sidebar column's own width only shrinks to
    # a 72px icon gutter while every one of its sections is collapsed (see
    # scss-src/_panels.scss's ":has(.prism-collapsible-panel):not(:has(...open))"
    # rule) — a section left OUT of that treatment still renders at its
    # normal full width/height inside that shrunk 72px column, wrapping
    # every word onto its own line (or, depending on its own CSS, spilling
    # out unclipped over the main content) instead of collapsing cleanly
    # alongside Filters. A host's own custom sidebar block (e.g. a "More
    # Actions" link list) hit exactly this before this file generalized
    # the treatment to cover it too.
    #
    # A host can pass its own icon via `sidebar "Title", icon: :list do
    # ... end` (any name from lib/prism_icons.rb) — anything else, plus
    # every section that predates this option, falls back to a generic
    # icon (:filter for the Filters section specifically, matching its
    # pre-existing look; :list for everything else).
    #
    # This only runs when ActiveAdminPrism.configuration.collapsible_filters
    # is true — when it's false, every section is left exactly as
    # ActiveAdmin renders it by default (plain text title, no icon, never
    # collapsed).
    class SidebarSection < Panel
      FILTERS_SECTION_ID = "filters_sidebar_section"
      DEFAULT_ICON = :list

      def build(section)
        @section = section
        super(@section.title)
        add_class @section.custom_class if @section.custom_class
        self.id = @section.id

        if ActiveAdminPrism.configuration.collapsible_filters
          add_class "prism-collapsible-panel"

          # Panel#build already appended the plain-text @title (h3) as the
          # first child, followed by @contents (the panel_contents div).
          # Replace it with an [icon, label-span] version — built fresh
          # rather than mutated in place (Arbre elements don't expose an
          # API to insert content before an existing child).
          #
          # Panel#add_child redirects *any* add_child call on this object to
          # @contents once @contents exists (so plain builder calls inside a
          # panel's do-block land in .panel_contents, not as top-level
          # siblings) — building a fresh h3 via the normal `h3(...)` verb at
          # this point would silently land *inside* .panel_contents instead
          # of replacing @title. Building it while @contents is
          # (temporarily) nil bypasses that redirect — but add_child still
          # *appends* (to the end of `children`, after the contents div,
          # since that div itself is still sitting in `children` even
          # though the @contents variable is momentarily nil), so it has to
          # be explicitly deleted from wherever it landed before unshifting
          # it to the front — otherwise it ends up in `children` twice.
          children.delete(@title)
          icon = ActiveAdminPrism::Icons.svg(icon_name, css_class: "prism-filter-icon")
          contents = @contents
          @contents = nil
          new_title = h3 do
            text_node icon.html_safe if icon
            span @section.title.to_s, class: "prism-filter-label"
          end
          @contents = contents

          children.delete(new_title)
          children.unshift(new_title)
          @title = new_title
        end

        build_sidebar_content
      end

      private

      # `options[:icon]` is a new convention this gem adds to the stock
      # `sidebar "Title", only: [...] do ... end` DSL — ActiveAdmin::
      # SidebarSection itself just stores the whole options hash
      # untouched, so a host can already pass `icon:` today without any
      # of their own version needing to change; it's a no-op until this
      # gem starts reading it here.
      def icon_name
        return @section.options[:icon] if @section.options[:icon]
        return :filter if @section.id == FILTERS_SECTION_ID

        DEFAULT_ICON
      end
    end
  end
end
