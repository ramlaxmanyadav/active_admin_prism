# frozen_string_literal: true

module ActiveAdmin
  module Views
    # Reopens ActiveAdmin::Views::SidebarSection (used for every sidebar
    # section, e.g. "Filters", "Search Status", any custom
    # `sidebar :title do ... end` block) to inject a real inline SVG icon
    # into the title of the *Filters* section specifically — matching the
    # id ActiveAdmin::SidebarSection#id computes for it
    # ("filters_sidebar_section"). Every other sidebar section is untouched.
    #
    # The label text is wrapped in its own span so CSS can visually hide it
    # while collapsed without touching the icon (see
    # scss-src/_panels.scss's #filters_sidebar_section rules, and
    # prism.js's filters-collapse handler for the actual toggle).
    #
    # This only runs when ActiveAdminPrism.configuration.collapsible_filters
    # is true — when it's false the section is left exactly as ActiveAdmin
    # renders it by default (plain text title, no icon).
    class SidebarSection < Panel
      FILTERS_SECTION_ID = "filters_sidebar_section"

      def build(section)
        @section = section
        super(@section.title)
        add_class @section.custom_class if @section.custom_class
        self.id = @section.id

        if @section.id == FILTERS_SECTION_ID && ActiveAdminPrism.configuration.collapsible_filters
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
          icon = ActiveAdminPrism::Icons.svg(:filter, css_class: "prism-filter-icon")
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
    end
  end
end
