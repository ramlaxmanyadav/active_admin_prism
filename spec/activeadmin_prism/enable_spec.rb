require "rails_helper"

RSpec.describe ActiveAdminPrism, ".enable!" do
  # Unlike colorize_action_icons/sidebar_footer/etc (read fresh on every
  # request), config.sidebar is only ever consulted once, right here, when
  # a host calls ActiveAdminPrism.enable! from its initializer at boot —
  # it decides whether to make one, permanent ActiveAdmin::ViewFactory
  # registration. That's why this is a unit test against .enable! itself
  # rather than a request spec toggling config between two HTTP calls: the
  # dummy app's initializer has already called enable! once by the time
  # any request spec runs, so mutating config.sidebar afterwards can't
  # un-register (or re-register) the header class for later requests.
  after { ActiveAdminPrism.reset_configuration! }

  it "registers PrismSidebar as ActiveAdmin's header when config.sidebar is true" do
    ActiveAdminPrism.configuration.sidebar = true

    expect(ActiveAdmin::ViewFactory).to receive(:register).with(header: ActiveAdmin::Views::PrismSidebar)

    ActiveAdminPrism.enable!
  end

  it "does not touch header registration when config.sidebar is false" do
    ActiveAdminPrism.configuration.sidebar = false

    expect(ActiveAdmin::ViewFactory).not_to receive(:register)

    ActiveAdminPrism.enable!
  end

  it "always returns true" do
    expect(ActiveAdminPrism.enable!).to be true
  end
end
