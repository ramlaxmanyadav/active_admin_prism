require "rails_helper"

RSpec.describe "Prism sidebar", type: :request do
  let!(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  before { sign_in admin_user }

  it "swaps ActiveAdmin's stock top nav for the Prism sidebar by default" do
    get "/admin"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('class="prism-sidebar" id="header"')
    expect(response.body).to include("prism-nav-item")
  end

  it "renders 'Powered by Active Admin' inside the sidebar footer by default" do
    get "/admin"

    expect(response.body).to include('class="prism-sidebar-footer"')
    expect(response.body).to include("Active Admin")
  end

  it "renders a menu search box above the Pages nav by default" do
    get "/admin"

    expect(response.body).to include('class="prism-sidebar-search"')
    expect(response.body).to include('data-prism-nav-search="true"')
  end

  context "when config.menu_search is false" do
    before { ActiveAdminPrism.configure { |c| c.menu_search = false } }

    it "does not render the search box" do
      get "/admin"

      expect(response.body).not_to include('class="prism-sidebar-search"')
    end
  end

  context "when config.sidebar_footer is false" do
    before { ActiveAdminPrism.configure { |c| c.sidebar_footer = false } }

    it "does not render the sidebar's own footer div" do
      get "/admin"

      expect(response.body).not_to include('class="prism-sidebar-footer"')
    end

    it "adds the prism-sidebar-footer-disabled body class" do
      get "/admin"

      expect(response.body).to match(/<body[^>]*\bprism-sidebar-footer-disabled\b/)
    end
  end

  it "does not add the prism-select2-enabled body class by default" do
    get "/admin"

    expect(response.body).not_to include("prism-select2-enabled")
  end

  context "when config.select2 is true" do
    before { ActiveAdminPrism.configure { |c| c.select2 = true } }

    it "adds the prism-select2-enabled body class" do
      get "/admin"

      expect(response.body).to match(/<body[^>]*\bprism-select2-enabled\b/)
    end
  end
end
