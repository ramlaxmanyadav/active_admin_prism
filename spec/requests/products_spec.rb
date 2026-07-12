require "rails_helper"

RSpec.describe "Products (index/show/form reskin)", type: :request do
  let!(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }
  let!(:product) { Product.create!(name: "Widget", price: 9.99, active: true) }

  before { sign_in admin_user }

  describe "index" do
    it "renders prism_toggle_tag for the boolean column" do
      get "/admin/products"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-toggle-tag on"')
    end

    it "colorizes row actions as icon buttons by default" do
      get "/admin/products"

      expect(response.body).to include("view_link")
      expect(response.body).to include("edit_link")
      expect(response.body).to include("delete_link")
      expect(response.body).to include("prism-action-icon")
      expect(response.body).to include("prism-visually-hidden")
    end

    it "falls back to plain text links when colorize_action_icons is false" do
      ActiveAdminPrism.configure { |c| c.colorize_action_icons = false }

      get "/admin/products"

      expect(response.body).not_to include("prism-action-icon")
      expect(response.body).to include(">View<")
    end

    it "collapses the Filters sidebar panel to an icon by default" do
      get "/admin/products"

      expect(response.body).to include("prism-collapsible-panel")
      expect(response.body).to include("prism-filter-icon")
    end

    it "leaves the Filters panel fully expanded when collapsible_filters is false" do
      ActiveAdminPrism.configure { |c| c.collapsible_filters = false }

      get "/admin/products"

      expect(response.body).not_to include("prism-collapsible-panel")
    end
  end

  describe "show" do
    it "renders prism_toggle_tag for the boolean row" do
      get "/admin/products/#{product.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-toggle-tag on"')
    end
  end

  describe "new" do
    it "renders the opt-in prism_toggle form input" do
      get "/admin/products/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-toggle"')
      expect(response.body).to include("prism-toggle-input")
      expect(response.body).to include("prism-toggle-track")
    end
  end
end
