require "rails_helper"

RSpec.describe ActiveAdminPrism::Configuration do
  after { ActiveAdminPrism.reset_configuration! }

  describe "defaults" do
    subject(:config) { described_class.new }

    it "defaults every boolean feature flag to on" do
      expect(config.sidebar).to be true
      expect(config.colorize_action_icons).to be true
      expect(config.styled_confirms).to be true
      expect(config.collapsible_filters).to be true
      expect(config.sidebar_footer).to be true
      expect(config.flash_dismissible).to be true
      expect(config.flash_auto_dismiss).to be true
      expect(config.login_page).to be true
    end

    it "defaults the flash timing values" do
      expect(config.flash_auto_dismiss_seconds).to eq(5)
      expect(config.flash_transition_ms).to eq(320)
    end

    it "defaults login_logo/login_app_name to nil (built-in fallback)" do
      expect(config.login_logo).to be_nil
      expect(config.login_app_name).to be_nil
    end

    it "defaults login_tagline to a friendly sentence" do
      expect(config.login_tagline).to eq("Sign in to your admin dashboard")
    end

    it "defaults select2 to off (opt-in, unlike the other feature flags)" do
      expect(config.select2).to be false
    end
  end

  describe ".configuration" do
    it "memoizes a single instance" do
      expect(ActiveAdminPrism.configuration).to equal(ActiveAdminPrism.configuration)
    end
  end

  describe ".configure" do
    it "yields the shared configuration instance for mutation" do
      ActiveAdminPrism.configure { |config| config.sidebar = false }

      expect(ActiveAdminPrism.configuration.sidebar).to be false
    end
  end

  describe ".reset_configuration!" do
    it "restores every flag to its default after mutation" do
      ActiveAdminPrism.configure do |config|
        config.sidebar = false
        config.login_tagline = "Custom"
      end

      ActiveAdminPrism.reset_configuration!

      expect(ActiveAdminPrism.configuration.sidebar).to be true
      expect(ActiveAdminPrism.configuration.login_tagline).to eq("Sign in to your admin dashboard")
    end
  end
end
