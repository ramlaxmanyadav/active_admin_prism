# frozen_string_literal: true

module ActiveAdmin
  module Filters
    # ActiveAdmin core auto-registers this sidebar section on every resource
    # (see active_admin/filters/resource_extension.rb#add_search_status_sidebar_section)
    # to summarize the current scope + active filters inside #sidebar,
    # alongside the Filters form. Skip it entirely when
    # ActiveAdminPrism.configuration.active_filters_bar is on — see
    # active_filters_bar.rb's Pages::Index override, which renders the same
    # content next to Batch Actions instead.
    class ActiveSidebar
      def sidebar_options
        {
          only: :index,
          if: -> {
            active_admin_config.current_filters_enabled? &&
              (params[:q] || params[:scope]) &&
              !ActiveAdminPrism.configuration.active_filters_bar
          }
        }
      end
    end
  end

  module Views
    module Pages
      # Relocates the "Search status" summary (current scope + active
      # filters — AA core's ActiveAdmin::Filters::ActiveSidebar, reopened
      # above to skip its normal #sidebar rendering when this is on) into
      # the same row as the Batch Actions button/scopes tabs (AA core's own
      # ".table_tools", rendered by Pages::Index#build_table_tools) instead
      # of ActiveAdmin's own #sidebar.
      #
      # Why not #sidebar: ActiveAdminPrism.configuration.collapsible_filters
      # squeezes the *entire* #sidebar column down to a 72px icon gutter
      # while the Filters form is collapsed (scss-src/_panels.scss) — every
      # child of #sidebar shrinks with it, this section included. Its
      # content (one "field contains value" sentence per active filter) has
      # nowhere to fit in 72px and overflows out over the table instead of
      # shrinking cleanly.
      #
      # ActiveAdminPrism::Configuration#active_filters_bar controls this —
      # false restores ActiveAdmin's stock behavior (rendered inside
      # #sidebar, squeezed along with it when collapsible_filters is on).
      class Index
        # AA core's own #build_table_tools (active_admin/views/pages/index.rb)
        # only renders ".table_tools" at all `if any_table_tools?` (batch
        # actions, scopes, or multiple index presenters) — grouping the
        # controls it does render into their own ".table_tools_actions" wrapper
        # (a new element, not AA's) is what lets scss-src/_panels.scss push
        # this bar to the opposite end of the same flex row via
        # `justify-content: space-between` regardless of whether that group
        # is present at all, rather than only ever being able to sit beside
        # it when it happens to exist.
        def build_table_tools
          show_bar = active_filters_bar?
          return unless any_table_tools? || show_bar

          div class: "table_tools" do
            if any_table_tools?
              div class: "table_tools_actions" do
                build_batch_actions_selector
                build_scopes
                build_index_list
              end
            end
            build_active_filters_bar if show_bar
          end
        end

        def active_filters_bar?
          return false unless ActiveAdminPrism.configuration.active_filters_bar
          return false unless active_admin_config
          # active_admin_config should always be an ActiveAdmin::Resource here
          # (only a Resource's :index action ever reaches Pages::Index), but
          # #current_filters_enabled? is defined via Filters::ResourceExtension
          # rather than on ActiveAdmin::Config itself — guard rather than
          # assume, the same defensive style as the rest of this gem.
          return false unless active_admin_config.respond_to?(:current_filters_enabled?)
          return false unless active_admin_config.current_filters_enabled?

          (params[:q] || params[:scope]).present?
        end

        def build_active_filters_bar
          div id: "prism_active_filters_bar", class: "prism-active-filters-bar" do
            active_filters_sidebar_content
          end
        end
      end
    end
  end
end
