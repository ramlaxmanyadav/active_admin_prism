require "rails_helper"

RSpec.describe "Sign-up page", type: :request do
  describe "GET /admin/sign_up" do
    it "renders the shared branded card with its own page-specific subtitle" do
      get "/admin/sign_up"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-login-brand"')
      expect(response.body).to include('class="prism-login-title">Prism Dummy<')
      expect(response.body).to include('class="prism-login-tagline">Sign up<')
    end

    it "sets the page title via the sign_up action's own translation" do
      get "/admin/sign_up"

      expect(response.body).to include("<title>Sign up | Prism Dummy</title>")
    end

    it "renders the full-width submit button styling hook" do
      get "/admin/sign_up"

      expect(response.body).to include('class="action input_action ')
    end

    context "when config.login_page is false" do
      before { ActiveAdminPrism.configure { |c| c.login_page = false } }

      it "renders ActiveAdmin's plain stock heading instead" do
        get "/admin/sign_up"

        expect(response.body).not_to include("prism-login-brand")
        expect(response.body).to include("<h2>Prism Dummy Sign up</h2>")
      end
    end
  end
end
