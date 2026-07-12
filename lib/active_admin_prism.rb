# frozen_string_literal: true

require "active_admin"

require_relative "active_admin_prism/version"
require_relative "active_admin_prism/configuration"
require_relative "active_admin_prism/engine"
require_relative "prism_icons"
require_relative "prism_toggle_tag"
require_relative "prism_login_helper"
require_relative "active_admin/views/prism_sidebar"
require_relative "active_admin/views/index_table_actions"
require_relative "active_admin/views/flash_messages"
require_relative "active_admin/views/filters_sidebar"
require_relative "formtastic/inputs/prism_toggle_input"

module ActiveAdminPrism
  class Error < StandardError; end

  # Swaps ActiveAdmin's default top navigation ("header") for Prism's
  # collapsible left sidebar, unless disabled via
  # `configure { |c| c.sidebar = false }`. Call once from
  # config/initializers/active_admin.rb (the install generator does this
  # automatically).
  #
  # This is a supported ActiveAdmin extension point, not a monkeypatch: see
  # ActiveAdmin::ViewFactory / AbstractViewFactory#add_writer, which wires the
  # "header" builder verb used by ActiveAdmin::Views::Pages::Base#build_page.
  def self.enable!
    ActiveAdmin::ViewFactory.register(header: ActiveAdmin::Views::PrismSidebar) if configuration.sidebar
    true
  end
end
