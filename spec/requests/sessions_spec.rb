require "rails_helper"

RSpec.describe "Sign-in page", type: :request do
  let!(:admin_user) { AdminUser.create!(email: "admin@example.com", password: "password123") }

  describe "GET /admin/login" do
    it "renders the branded card by default" do
      get "/admin/login"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="prism-login-brand"')
      expect(response.body).to include('class="prism-login-title">Prism Dummy<')
      expect(response.body).to include('class="prism-login-tagline">Sign in to your admin dashboard<')
    end

    it "renders the built-in animated mark by default" do
      get "/admin/login"

      expect(response.body).to include("prism-login-mark")
    end

    it "sets the page title via the login action's own translation" do
      get "/admin/login"

      expect(response.body).to include("<title>Login | Prism Dummy</title>")
    end

    context "with a custom login_app_name/login_logo/login_tagline" do
      before do
        ActiveAdminPrism.configure do |config|
          config.login_app_name = "My Company Admin"
          config.login_tagline = "Internal console"
          config.login_logo = -> { prism_icon(:cart, size: 40) }
        end
      end

      it "renders the overrides instead of the defaults" do
        get "/admin/login"

        expect(response.body).to include('class="prism-login-title">My Company Admin<')
        expect(response.body).to include('class="prism-login-tagline">Internal console<')
        expect(response.body).not_to include("prism-login-mark")
      end
    end

    context "when config.login_page is false" do
      before { ActiveAdminPrism.configure { |c| c.login_page = false } }

      it "renders ActiveAdmin's plain stock heading instead" do
        get "/admin/login"

        expect(response.body).not_to include("prism-login-brand")
        expect(response.body).to include("<h2>Prism Dummy Login</h2>")
      end
    end
  end

  describe "POST /admin/login" do
    it "signs in with valid credentials and redirects to the dashboard" do
      post "/admin/login", params: { admin_user: { email: admin_user.email, password: "password123" } }

      expect(response).to redirect_to("/admin")
    end

    it "re-renders the branded card with an error on invalid credentials" do
      post "/admin/login", params: { admin_user: { email: admin_user.email, password: "wrong" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('class="prism-login-brand"')
    end
  end
end
