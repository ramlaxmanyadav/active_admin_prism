require "rails_helper"

RSpec.describe "Flash messages", type: :request do
  let!(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  before { sign_in admin_user }

  describe "the .flashes wrapper" do
    it "always carries the configured transition/auto-dismiss timing as data attributes" do
      get "/admin"

      expect(response.body).to match(/class="flashes" data-prism-transition-ms="320" data-prism-auto-dismiss-ms="\d+"/)
    end

    it "omits the auto-dismiss attribute when flash_auto_dismiss is false" do
      ActiveAdminPrism.configure { |c| c.flash_auto_dismiss = false }

      get "/admin"

      expect(response.body).to include('data-prism-transition-ms="320"')
      expect(response.body).not_to include("data-prism-auto-dismiss-ms")
    end

    it "renders a configured flash_transition_ms" do
      ActiveAdminPrism.configure { |c| c.flash_transition_ms = 500 }

      get "/admin"

      expect(response.body).to include('data-prism-transition-ms="500"')
    end
  end

  describe "an actual flash message" do
    # Deleting a product is a reliable, no-extra-setup way to land on an
    # authenticated page (the redirected-to index) with a real flash[:notice]
    # set — this goes through ActiveAdmin::Views::Pages::Base, unlike the
    # sign-in page's own flash (rendered by ActiveAdmin's separate,
    # untouched layouts/active_admin_logged_out.html.erb — see
    # INTEGRATION.md's "Sign-in page" section for why that one specific
    # page can't route through this same build_flash_messages override).
    let!(:product) { Product.create!(name: "Widget") }

    it "wraps the message with a dismiss button by default" do
      delete "/admin/products/#{product.id}"
      follow_redirect!

      expect(response.body).to include('class="prism-flash-dismiss"')
      expect(response.body).to include("prism-flash-dismiss-icon")
    end

    it "renders a plain flash div with no dismiss button when flash_dismissible is false" do
      ActiveAdminPrism.configure { |c| c.flash_dismissible = false }
      delete "/admin/products/#{product.id}"
      follow_redirect!

      expect(response.body).not_to include("prism-flash-dismiss")
    end
  end
end
