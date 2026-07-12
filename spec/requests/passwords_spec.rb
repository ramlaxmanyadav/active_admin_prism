require "rails_helper"

RSpec.describe "Forgot-password page", type: :request do
  describe "GET /admin/password/new" do
    it "renders the shared branded card with its own page-specific subtitle" do
      get "/admin/password/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-login-brand"')
      expect(response.body).to include('class="prism-login-tagline">Forgot your password?<')
    end

    it "sets the page title via the reset_password action's own translation" do
      get "/admin/password/new"

      expect(response.body).to include("<title>Forgot your password? | Prism Dummy</title>")
    end

    it "renders the sign-in/sign-up link chips" do
      get "/admin/password/new"

      expect(response.body).to include('class="prism-login-links"')
      expect(response.body).to include(">Sign in<")
      expect(response.body).to include(">Sign up<")
    end

    context "when config.login_page is false" do
      before { ActiveAdminPrism.configure { |c| c.login_page = false } }

      it "renders ActiveAdmin's plain stock heading instead" do
        get "/admin/password/new"

        expect(response.body).not_to include("prism-login-brand")
        expect(response.body).to include("<h2>Prism Dummy Forgot your password?</h2>")
      end
    end
  end
end
